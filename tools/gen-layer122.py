# -*- coding: utf-8 -*-
"""Sinh MxApiLayer122.swift — các parser đọc payload layer 12.2 (iMe).

Mọi thứ ở đây khoá theo **(kiểu Api, tên constructor)**, không theo tên. 20 tên
tồn tại ở hai namespace khác nhau — `starGiftAuctionState` có cả ở
`Api.StarGiftAuctionState` lẫn `Api.payments.StarGiftAuctionState`, với hai id
khác nhau — nên khoá theo tên là ghép nhầm cặp.

Hai loại đầu ra:

  * Constructor mà parser hiện tại đọc được payload cũ (trường 12.9 thêm vào đều
    nằm sau bit canh máy chủ 12.2 không bật): chỉ cần vỏ bọc gọi lại parser đó.
  * Constructor có bố cục thật sự khác: lấy nguyên thân hàm parse của 12.2 — nó
    là mã sinh tự động, tự đủ — rồi thay câu return bằng initializer Cons_ hiện
    tại, truyền nil/0 cho trường 12.2 chưa có.

Kiểu enum-có-giá-trị-kèm của 12.2 ghi thẳng nhãn trường trong câu return
(`Api.X.y(text: _1!, url: _2!)`), nên ánh xạ sang tham số initializer hiện tại là
theo tên chứ không theo vị trí — đoán vị trí là chỗ dễ sai nhất.
"""
import re, glob, os, json
from collections import defaultdict

# Nguồn 12.2 tải về bằng:
#   gh api "repos/TelegramMessenger/Telegram-iOS/contents/submodules/TelegramApi/Sources/ApiN.swift?ref=release-12.2"
# rồi lưu thành ApiN_122.swift trong OLD_DIR.
OLD_DIR = os.environ.get('MX_API122_DIR', os.path.dirname(os.path.abspath(__file__)))
NEW_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       '..', 'Sources', 'tgapi', 'api_sources')

EXT = re.compile(r'^public extension (Api(?:\.[A-Za-z0-9_]+)*) \{', re.M)
ENUM = re.compile(r'^\s*(?:public )?(?:indirect )?enum ([A-Za-z0-9_]+): TypeConstructorDescription \{', re.M)
FUNC = re.compile(r'static func parse_([A-Za-z0-9_]+)\(_ reader: BufferReader\)[^\n]*\{')


def index(paths):
    """{(kiểu đầy đủ, tên): thân hàm parse}"""
    out = {}
    for p in paths:
        s = open(p, encoding='utf-8', errors='ignore').read()
        # mốc: mỗi extension mở một namespace, mỗi enum mở một kiểu
        marks = [(m.start(), 'ext', m.group(1)) for m in EXT.finditer(s)]
        marks += [(m.start(), 'enum', m.group(1)) for m in ENUM.finditer(s)]
        marks += [(m.start(), 'func', m) for m in FUNC.finditer(s)]
        marks.sort(key=lambda x: x[0])
        ns, enum = 'Api', None
        for _, kind, val in marks:
            if kind == 'ext':
                ns = val
            elif kind == 'enum':
                enum = val
            else:
                if enum is None:
                    continue
                m = val
                i, depth = m.end(), 1
                while i < len(s) and depth:
                    if s[i] == '{':
                        depth += 1
                    elif s[i] == '}':
                        depth -= 1
                    i += 1
                out[(f'{ns}.{enum}', m.group(1))] = s[m.end():i - 1]
    return out


def id_table(path):
    """{(kiểu, tên): id} lấy từ bảng đăng ký."""
    out = {}
    for line in open(path, encoding='utf-8'):
        m = re.match(r'\s*dict\[(-?\d+)\] = \{ return (Api\.[A-Za-z0-9_.]+)\.parse_([A-Za-z0-9_]+)\(\$0\) \}', line)
        if m:
            out[(m.group(2), m.group(3))] = int(m.group(1))
    return out


OLD = index(sorted(glob.glob(os.path.join(OLD_DIR, 'Api*_122.swift'))))
NEW = index(sorted(glob.glob(os.path.join(NEW_DIR, 'Api*.swift'))))
OLD_IDS = id_table(os.path.join(OLD_DIR, 'Api0_122.swift'))
NEW_IDS = id_table(os.path.join(NEW_DIR, 'Api0.swift'))

# 12.2 và 12.8 định nghĩa giống hệt nhau ba kiểu này, nên id trùng và một id
# trùng chỉ chứng minh "cũ hơn 12.9". MxApiCompat đã đăng ký riêng, báo cận trên
# thay vì báo lớp; sinh thêm ở đây sẽ đè lên và kết luận sai 12.2 trên máy 12.8.
SHARED_WITH_128 = {('Api.User', 'user'), ('Api.Chat', 'channel'),
                   ('Api.BotCommand', 'botCommand')}

changed = sorted(k for k in OLD_IDS
                 if k in NEW_IDS and OLD_IDS[k] != NEW_IDS[k] and k not in SHARED_WITH_128)

# ── đọc được payload cũ bằng parser mới không? ────────────────────────────
READ = re.compile(r'_(\d+) = (reader\.read\w+\(\)|parseString\(reader\)|Api\.parse\(|Api\.parseVector|reader\.readBytes)')
GUARD = re.compile(r'Int\((_\d+)!?\s*\?\?\s*0\)?\s*&\s*Int\(1 << (\d+)\)|Int\((_\d+)!\)\s*&\s*Int\(1 << (\d+)\)')


def fields(body):
    out, pending = [], None
    for line in body.split('\n'):
        g = GUARD.search(line)
        if g:
            pending = ((g.group(1) or g.group(3)), int(g.group(2) or g.group(4)))
        reads = list(READ.finditer(line))
        for _ in reads:
            out.append(pending)
            pending = None
        if reads:
            pending = None
    return out


def readable_by_current(key):
    of, nf = fields(OLD[key]), fields(NEW[key])
    j = 0
    for oguard in of:
        while j < len(nf):
            if nf[j] == oguard:
                j += 1
                break
            if nf[j] is None:
                return False
            j += 1
        else:
            return False
    return all(g is not None for g in nf[j:])


# ── ánh xạ sang initializer hiện tại ──────────────────────────────────────
RETURN = re.compile(r'return (Api\.[A-Za-z0-9_.]+)\.([A-Za-z0-9_]+)\((.*?)\)\s*\n', re.S)
INIT_T = r'public class Cons_%s: TypeConstructorDescription \{.*?public init\((.*?)\) \{'

NEW_SRC = {p: open(p, encoding='utf-8', errors='ignore').read()
           for p in sorted(glob.glob(os.path.join(NEW_DIR, 'Api*.swift')))}

EXPLICIT_DEFAULTS = {
    # Trường bắt buộc mà 12.2 chưa có gì để điền. Chỉ ảnh hưởng phần hiển thị
    # của tính năng không thuộc tweak.
    'Api.StarGiftAttributeRarity':
        'Api.StarGiftAttributeRarity.starGiftAttributeRarity('
        'Api.StarGiftAttributeRarity.Cons_starGiftAttributeRarity(permille: 0))',
}


def split_args(text):
    parts, depth, cur = [], 0, ''
    for ch in text:
        if ch in '([<':
            depth += 1
        elif ch in ')]>':
            depth -= 1
        if ch == ',' and depth == 0:
            parts.append(cur); cur = ''
        else:
            cur += ch
    if cur.strip():
        parts.append(cur)
    return parts


def old_return_args(body, name):
    for m in RETURN.finditer(body):
        if m.group(2) != name:
            continue
        args = {}
        for part in split_args(m.group(3)):
            if ':' not in part:
                return None
            label, expr = part.split(':', 1)
            args[label.strip()] = expr.strip()
        return args
    return None


def new_init_params(api_type, name):
    """Tham số của Cons_<name> nằm trong đúng kiểu api_type."""
    for p, s in NEW_SRC.items():
        if (api_type, name) not in {(k[0], k[1]) for k in NEW if k[0] == api_type}:
            pass
        for m in re.finditer(INIT_T % re.escape(name), s, re.S):
            # xác nhận đúng namespace bằng cách soi ngược tới enum bao ngoài
            head = s[:m.start()]
            ext = EXT.findall(head)
            en = ENUM.findall(head)
            if not en:
                continue
            full = f'{ext[-1] if ext else "Api"}.{en[-1]}'
            if full != api_type:
                continue
            return [(a.split(':', 1)[0].strip(), a.split(':', 1)[1].strip())
                    for a in split_args(m.group(1))]
    return None


def default_for(ptype):
    if ptype in EXPLICIT_DEFAULTS:
        return EXPLICIT_DEFAULTS[ptype]
    if ptype.endswith('?'):
        return 'nil'
    if ptype in ('Int32', 'Int64', 'Int', 'Double'):
        return '0'
    if ptype == 'String':
        return '""'
    if ptype.startswith('['):
        return '[]'
    return None


by_type, problems, registrations = defaultdict(list), [], []

for key in changed:
    api_type, name = key
    if key not in OLD or key not in NEW:
        problems.append((key, 'không tìm thấy parser ở một trong hai bản'))
        continue
    registrations.append((OLD_IDS[key], api_type, name))

    if readable_by_current(key):
        by_type[api_type].append(('passthrough', name, None))
        continue

    args = old_return_args(OLD[key], name)
    if args is None:
        problems.append((key, 'không đọc được câu return của 12.2'))
        continue
    params = new_init_params(api_type, name)
    if params is None:
        problems.append((key, 'không tìm thấy Cons_ hiện tại'))
        continue

    call, missing = [], []
    for pname, ptype in params:
        if pname in args:
            call.append(f'{pname}: {args[pname]}')
        else:
            d = default_for(ptype)
            if d is None:
                missing.append(f'{pname}: {ptype}')
            else:
                call.append(f'{pname}: {d}')
    if missing:
        problems.append((key, 'trường mới không có giá trị mặc định: ' + ', '.join(missing)))
        continue

    body = OLD[key]
    cut = body.find('if _c1')
    conds = None
    if cut == -1:
        cut = body.find('return Api.')
    else:
        cm = re.search(r'if (_c1[^\{]*)\{', body)
        conds = cm.group(1).strip() if cm else None
    by_type[api_type].append(('full', name, (body[:cut].rstrip(), conds, call)))

# ── xuất file ─────────────────────────────────────────────────────────────
out = ['import Foundation', '',
       '// SINH TỰ ĐỘNG bởi tools/gen-layer122.py — đừng sửa tay.',
       '//',
       '// Đọc payload của Telegram layer 12.2. 71 constructor đổi id giữa 12.2 và',
       '// 12.9.2 và không cái nào bị bỏ, nên mọi thứ ở đây là đọc bố cục cũ rồi',
       '// dựng lại bằng kiểu hiện tại.',
       '//',
       '// CHƯA CLIENT NÀO DÙNG TỚI. Viết cho iMe vì Info.plist của nó ghi',
       '// CFBundleShortVersionString 12.2.7 — đó là số phiên bản riêng của iMe,',
       '// không phải bản Telegram nền. Đo trên dây, iMe gửi message#1979759059',
       '// cùng user#829899656 và channel#473084188, đúng tổ hợp của release-12.8.',
       '// Giữ lại vì đã kiểm ngoại tuyến và không tốn gì khi nằm im: những id này',
       '// đơn giản là không bao giờ tới. Xem MxApiCompat.swift.',
       '']

for api_type in sorted(by_type):
    out.append(f'public extension {api_type} {{')
    for kind, name, payload in sorted(by_type[api_type], key=lambda x: x[1]):
        if kind == 'passthrough':
            out += [f'    /// {name} như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm',
                    f'    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc',
                    f'    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.',
                    f'    static func parse_{name}_l122(_ reader: BufferReader) -> {api_type}? {{',
                    f'        MxApiCompat.note(.l122)',
                    f'        return parse_{name}(reader)',
                    '    }', '']
        else:
            reads, conds, call = payload
            out += [f'    /// {name} như 12.2 định nghĩa — bố cục khác thật, không dùng lại',
                    f'    /// parser hiện tại được.',
                    f'    static func parse_{name}_l122(_ reader: BufferReader) -> {api_type}? {{',
                    f'        MxApiCompat.note(.l122)']
            for line in reads.split('\n'):
                if line.strip():
                    out.append(line[8:] if line.startswith('        ') else '        ' + line.strip())
            out.append(f'        if {conds} {{' if conds else '        if true {')
            out += [f'            return {api_type}.{name}(Cons_{name}({", ".join(call)}))',
                    '        } else {', '            return nil', '        }', '    }', '']
    out += ['}', '']

open(os.path.join(NEW_DIR, 'MxApiLayer122.swift'), 'w', encoding='utf-8').write('\n'.join(out))

reg_lines = [f'    dict[{i}] = {{ return {t}.parse_{n}_l122($0) }}'
             for i, t, n in sorted(registrations, key=lambda x: (x[1], x[2]))]
open(os.path.join(OLD_DIR, 'registrations.txt'), 'w', encoding='utf-8').write('\n'.join(reg_lines) + '\n')

n_pass = sum(1 for v in by_type.values() for k, *_ in v if k == 'passthrough')
n_full = sum(1 for v in by_type.values() for k, *_ in v if k == 'full')
print(f'constructor đổi id: {len(changed)}')
print(f'  vỏ bọc (parser hiện tại đọc được): {n_pass}')
print(f'  viết đầy đủ (bố cục khác): {n_full}')
print(f'  dòng đăng ký: {len(reg_lines)}')
if problems:
    print(f'\nCẦN XEM TAY: {len(problems)}')
    for k, why in problems:
        print(f'  {k[0]}.{k[1]}: {why}')
