#!/usr/bin/env python3
"""Sinh EmbeddedLangs.h từ các Localizable.strings trong Mx.bundle.

Generates EmbeddedLangs.h from the Localizable.strings files in Mx.bundle.

Escaping note (this is what the previous version got wrong):
    A .strings file already stores values with C-style escapes, so a literal
    quote is written as \" and a literal backslash as \\. Objective-C string
    literals use the exact same escapes, so a correctly parsed value can be
    written straight into the header with no re-escaping at all.

    The old code ran val.replace('"', '\\"') over the raw line, which turned an
    existing \" into \\" . The compiler then read that as "backslash, then end
    of string", and every language after the offending line collapsed:

        EmbeddedLangs.h:111: error: expected '}' or ','
        EmbeddedLangs.h:128: error: expected identifier or '('   (x10)
        EmbeddedLangs.h:1265: error: extraneous closing brace ('}')

    It also used .strip('";') to remove the wrapping quotes, which chews
    through a trailing \" as well and leaves a dangling backslash.
"""

import argparse
import os
import re
import sys

# Mọi path suy ra từ vị trí script -> chạy được trên máy bất kỳ, không phụ thuộc CWD
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_BUNDLE = os.path.join(SCRIPT_DIR, "Mx.bundle")
DEFAULT_OUTPUT = os.path.join(SCRIPT_DIR, "Sources", "tgapi", "UI", "EmbeddedLangs.h")

# "KEY" = "VALUE";  where either side may contain backslash escapes.
# (?:[^"\\]|\\.)* consumes an escaped character as a single unit, so an escaped
# quote inside the value never ends the match early.
ENTRY_RE = re.compile(r'^\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;\s*$')


def c_string_is_balanced(value: str) -> bool:
    """Walk a value the way a C compiler scans a string literal body.

    Returns False if the value would terminate the literal early (an unescaped
    quote) or run off the end (a trailing lone backslash). This is the guard
    that would have caught the old bug before it ever reached clang.
    """
    i = 0
    while i < len(value):
        ch = value[i]
        if ch == "\\":
            if i + 1 >= len(value):
                return False  # dangling backslash: eats the closing quote
            i += 2
            continue
        if ch == '"':
            return False  # unescaped quote: ends the literal early
        i += 1
    return True


def parse_strings_file(path, problems):
    entries = []
    seen = set()
    in_block_comment = False

    with open(path, "r", encoding="utf-8") as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.strip()

            # Block comments may span lines, while single-line /* ... */ is
            # common in this bundle and must not swallow what follows it.
            if in_block_comment:
                if "*/" in line:
                    in_block_comment = False
                    line = line.split("*/", 1)[1].strip()
                else:
                    continue
            if line.startswith("/*") and "*/" not in line:
                in_block_comment = True
                continue
            if not line or line.startswith("//") or line.startswith("/*"):
                continue

            match = ENTRY_RE.match(line)
            if not match:
                # Loud rather than silent: a skipped line means a string that is
                # missing at runtime, which is much harder to spot than an error.
                problems.append(f"{path}:{lineno}: could not parse: {line}")
                continue

            key, value = match.group(1), match.group(2)

            if not c_string_is_balanced(key) or not c_string_is_balanced(value):
                problems.append(
                    f"{path}:{lineno}: broken escaping in {key!r} "
                    "(unescaped quote or trailing backslash)"
                )
                continue

            if key in seen:
                problems.append(f"{path}:{lineno}: duplicate key {key!r}")
                continue

            seen.add(key)
            entries.append((key, value))

    return entries


def main():
    parser = argparse.ArgumentParser(
        description="Sinh EmbeddedLangs.h từ các Localizable.strings trong Mx.bundle"
    )
    parser.add_argument(
        "--bundle", default=DEFAULT_BUNDLE,
        help=f"Đường dẫn Mx.bundle (mặc định: {DEFAULT_BUNDLE})",
    )
    parser.add_argument(
        "--output", default=DEFAULT_OUTPUT,
        help=f"File header xuất ra (mặc định: {DEFAULT_OUTPUT})",
    )
    parser.add_argument(
        "--strict", action="store_true",
        help="Thoát với lỗi nếu có dòng không parse được (dùng trong CI)",
    )
    args = parser.parse_args()

    bundle_path = args.bundle
    output_path = args.output

    if not os.path.isdir(bundle_path):
        raise SystemExit(f"Không tìm thấy bundle: {bundle_path}")

    # Sắp xếp để output ổn định giữa các lần chạy / các máy
    lprojs = sorted(d for d in os.listdir(bundle_path) if d.endswith(".lproj"))

    problems = []
    counts = {}

    # static inline: header được import từ nhiều .m, non-static sẽ gây duplicate symbol khi link
    out = "// Generated by generate_langs.py. Do not edit by hand.\n"
    out += "#import <Foundation/Foundation.h>\n\n"
    out += "static inline NSDictionary *GetAllTranslations(NSString *code) {\n"

    for lproj in lprojs:
        code = lproj.replace(".lproj", "")
        strings_path = os.path.join(bundle_path, lproj, "Localizable.strings")
        if not os.path.exists(strings_path):
            continue

        entries = parse_strings_file(strings_path, problems)
        counts[code] = len(entries)

        out += f'    if ([code isEqualToString:@"{code}"]) {{\n'
        out += "        return @{\n"
        for key, value in entries:
            # No re-escaping: .strings escapes are already valid ObjC escapes.
            out += f'            @"{key}": @"{value}",\n'
        out += "        };\n"
        out += "    }\n"

    out += "    return nil;\n}\n"

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(out)

    print(f"Đã ghi {output_path} ({len(counts)} ngôn ngữ)")
    for code in sorted(counts):
        print(f"  {code}: {counts[code]} keys")

    if problems:
        print("\nCảnh báo / Warnings:", file=sys.stderr)
        for p in problems:
            print(f"  {p}", file=sys.stderr)
        if args.strict:
            print(
                f"\n{len(problems)} problem(s) and --strict was passed.",
                file=sys.stderr,
            )
            return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
