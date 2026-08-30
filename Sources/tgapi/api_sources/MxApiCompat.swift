import Foundation
import os.log

// Speaking three TL layers at once.
//
// The bundled schema is Telegram's release-12.9.2, but a constructor id is a hash
// of its definition and the server sends whichever definition the *host app*
// negotiated with invokeWithLayer. Mx runs inside several clients and they do not
// ship the same Telegram version:
//
//     Telegram, Swiftgram   12.9.x   — the bundled schema
//     Turrit                12.8     — 6 constructor ids differ
//     iMe                   12.8     — measured on the wire, see below
//
// Parsing a constructor we do not know returns nil, and nil means the whole
// response goes through unpatched: on an older host every reply carrying a user
// or a channel — which is nearly all of them — would silently stop being
// rewritten. Serializing is the mirror danger: emitting a 12.9 id to an older
// host hands it bytes its own parser cannot read.
//
// So: accept every id on the way in, remember which layer the host speaks, and
// echo that same id on the way out.
//
// ── On the 12.2 support, which nothing currently uses ──────────────────────
//
// MxApiLayer122.swift carries 71 parsers for release-12.2 and they have never
// run against a real server. They were written for iMe on the strength of its
// Info.plist saying CFBundleShortVersionString 12.2.7 — which is iMe's own
// version number, not the Telegram release it is built on. Measured on the
// wire, iMe sends message#1979759059 with user#829899656 and channel#473084188,
// and that combination is exactly release-12.8.
//
// The code is kept because it is verified offline (a 12.2 message parses field
// for field and re-serializes to the same byte count under the 12.2 id) and
// costs nothing at rest: the ids it registers simply never arrive. If a client
// built on 12.2 ever turns up it is ready. Until then, treat `.l122` as
// untested against anything real.
enum MxApiLayer: Int, Comparable {
    case l122 = 122
    case l128 = 128
    case l129 = 129

    static func < (a: MxApiLayer, b: MxApiLayer) -> Bool { a.rawValue < b.rawValue }
}

enum MxApiCompat {
    // Constructor ids as of release-12.8. Only three of the six that changed
    // between 12.8 and 12.9 are ones this tweak ever writes back out.
    static let legacyUser: Int32 = 829899656
    static let legacyChannel: Int32 = 473084188
    static let legacyBotCommand: Int32 = -1032140601

    // 12.2 kept those same three definitions, so their ids are identical and seeing
    // one proves only "older than 12.9". Message is what separates the two: 12.8
    // already agreed with 12.9 about it, so this id can only have come from 12.2.
    static let l122Message: Int32 = -1188071729

    private static let defaultsKey = "MxHostApiLayer"

    /// The layer the host app turned out to speak.
    ///
    /// Seeded from disk because the first response of a session may well be one
    /// we have to re-serialize, and by then it is too late to start guessing. A
    /// host does not change version underneath a running process, and a tweak
    /// carried across an app update costs one launch to settle.
    static var layer: MxApiLayer = {
        let stored = UserDefaults.standard.integer(forKey: defaultsKey)
        return MxApiLayer(rawValue: stored) ?? .l129
    }()

    /// An id that belongs to exactly one layer settles the question outright,
    /// in either direction — so a tweak carried across an app update corrects
    /// itself the first time the new client answers.
    static func note(_ seen: MxApiLayer) {
        guard seen != layer else { return }
        let was = layer
        layer = seen
        UserDefaults.standard.set(seen.rawValue, forKey: defaultsKey)
        diag("layer \(was.rawValue) -> \(seen.rawValue) (định danh riêng của một lớp)")
    }

    /// An id that several layers share proves only an upper bound. Lowering the
    /// belief is sound; raising it on this evidence would undo what a definitive
    /// id already established.
    static func noteAtMost(_ ceiling: MxApiLayer) {
        guard layer > ceiling else { return }
        let was = layer
        layer = ceiling
        UserDefaults.standard.set(ceiling.rawValue, forKey: defaultsKey)
        diag("layer \(was.rawValue) -> \(ceiling.rawValue) (định danh dùng chung, chỉ hạ cận trên)")
    }

    // Which layer the host turned out to speak is the one fact this whole file
    // exists to establish, so it gets a line of its own rather than being
    // inferred from what did or did not get patched afterwards.
    //
    // Keep in step with MX_DIAG in Logger.h and TLParser.diagEnabled — three
    // switches for the same thing, because neither Swift file can see the C
    // macro and this one cannot see TLParser's private flag.
    private static let diagEnabled = false
    private static let diagLog = OSLog(subsystem: "com.m1ronx.mx", category: "diag")

    private static func diag(_ message: String) {
        guard diagEnabled else { return }
        // Not "api-layer:" — TLParser already uses that prefix to report
        // constructors it could not parse, and reading a log where the detected
        // layer and the parse failures share a tag is needlessly confusing.
        os_log("[MxDiag] host-layer: %{public}@", log: diagLog, type: .default, message)
    }

    /// Called once from the request path so the log opens with the layer in
    /// force, not just the moments it changed.
    static func diagReportCurrentLayer() {
        diag("đang dùng lớp \(layer.rawValue)")
    }

    /// Which id to write for a constructor whose definition changed.
    ///
    /// `l122` defaults to `legacy` because for most of what this tweak writes
    /// back the 12.2 and 12.8 ids are the same — only the ones that changed
    /// twice need spelling out.
    static func constructorId(current: Int32, legacy: Int32, l122: Int32? = nil) -> Int32 {
        switch layer {
        case .l129: return current
        case .l128: return legacy
        case .l122: return l122 ?? legacy
        }
    }
}

// The three definitions 12.8 and 12.2 share. Registered once, under the id both
// send, and reported as an upper bound rather than a layer.

public extension Api.User {
    /// user#31780a4a as everything before 12.9 defined it.
    ///
    /// The only difference is a trailing `linked_community_id` behind flags2 bit
    /// 21, a bit an older server never sets, so the current parser reads an old
    /// payload correctly on its own — all this wrapper adds is the note about
    /// which layer the host speaks.
    static func parse_user_legacyLayer(_ reader: BufferReader) -> Api.User? {
        MxApiCompat.noteAtMost(.l128)
        return parse_user(reader)
    }
}

public extension Api.Chat {
    /// channel#... before 12.9 — again a trailing optional behind a new flags2
    /// bit (20) that an older server never sets.
    static func parse_channel_legacyLayer(_ reader: BufferReader) -> Api.Chat? {
        MxApiCompat.noteAtMost(.l128)
        return parse_channel(reader)
    }
}

public extension Api.BotCommand {
    /// botCommand before 12.9: `command:string description:string`.
    ///
    /// This one genuinely cannot be read by the current parser — 12.9 put a
    /// `flags:#` in front, so the two layouts disagree from the first byte. It
    /// matters because bot commands ride inside chatFull, and one unreadable
    /// field there costs the whole reply.
    static func parse_botCommand_legacyLayer(_ reader: BufferReader) -> Api.BotCommand? {
        MxApiCompat.noteAtMost(.l128)
        guard let command = parseString(reader), let description = parseString(reader) else {
            return nil
        }
        return Api.BotCommand.botCommand(Cons_botCommand(flags: 0, command: command,
                                                         description: description))
    }
}
