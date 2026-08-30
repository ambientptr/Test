import Foundation

// SINH TỰ ĐỘNG bởi tools/gen-layer122.py — đừng sửa tay.
//
// Đọc payload của Telegram layer 12.2. 71 constructor đổi id giữa 12.2 và
// 12.9.2 và không cái nào bị bỏ, nên mọi thứ ở đây là đọc bố cục cũ rồi
// dựng lại bằng kiểu hiện tại.
//
// CHƯA CLIENT NÀO DÙNG TỚI. Viết cho iMe vì Info.plist của nó ghi
// CFBundleShortVersionString 12.2.7 — đó là số phiên bản riêng của iMe,
// không phải bản Telegram nền. Đo trên dây, iMe gửi message#1979759059
// cùng user#829899656 và channel#473084188, đúng tổ hợp của release-12.8.
// Giữ lại vì đã kiểm ngoại tuyến và không tốn gì khi nằm im: những id này
// đơn giản là không bao giờ tới. Xem MxApiCompat.swift.

public extension Api.ChannelParticipant {
    /// channelParticipant như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_channelParticipant_l122(_ reader: BufferReader) -> Api.ChannelParticipant? {
        MxApiCompat.note(.l122)
        return parse_channelParticipant(reader)
    }

    /// channelParticipantBanned như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_channelParticipantBanned_l122(_ reader: BufferReader) -> Api.ChannelParticipant? {
        MxApiCompat.note(.l122)
        return parse_channelParticipantBanned(reader)
    }

    /// channelParticipantSelf như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_channelParticipantSelf_l122(_ reader: BufferReader) -> Api.ChannelParticipant? {
        MxApiCompat.note(.l122)
        return parse_channelParticipantSelf(reader)
    }

}

public extension Api.ChatFull {
    /// channelFull như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_channelFull_l122(_ reader: BufferReader) -> Api.ChatFull? {
        MxApiCompat.note(.l122)
        return parse_channelFull(reader)
    }

}

public extension Api.ChatParticipant {
    /// chatParticipant như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_chatParticipant_l122(_ reader: BufferReader) -> Api.ChatParticipant? {
        MxApiCompat.note(.l122)
    var _1: Int64?
    _1 = reader.readInt64()
    var _2: Int64?
    _2 = reader.readInt64()
    var _3: Int32?
    _3 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
        if _c1 && _c2 && _c3 {
            return Api.ChatParticipant.chatParticipant(Cons_chatParticipant(flags: 0, userId: _1!, inviterId: _2!, date: _3!, rank: nil))
        } else {
            return nil
        }
    }

    /// chatParticipantAdmin như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_chatParticipantAdmin_l122(_ reader: BufferReader) -> Api.ChatParticipant? {
        MxApiCompat.note(.l122)
    var _1: Int64?
    _1 = reader.readInt64()
    var _2: Int64?
    _2 = reader.readInt64()
    var _3: Int32?
    _3 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
        if _c1 && _c2 && _c3 {
            return Api.ChatParticipant.chatParticipantAdmin(Cons_chatParticipantAdmin(flags: 0, userId: _1!, inviterId: _2!, date: _3!, rank: nil))
        } else {
            return nil
        }
    }

    /// chatParticipantCreator như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_chatParticipantCreator_l122(_ reader: BufferReader) -> Api.ChatParticipant? {
        MxApiCompat.note(.l122)
    var _1: Int64?
    _1 = reader.readInt64()
    let _c1 = _1 != nil
        if _c1 {
            return Api.ChatParticipant.chatParticipantCreator(Cons_chatParticipantCreator(flags: 0, userId: _1!, rank: nil))
        } else {
            return nil
        }
    }

}

public extension Api.ConnectedBot {
    /// connectedBot như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_connectedBot_l122(_ reader: BufferReader) -> Api.ConnectedBot? {
        MxApiCompat.note(.l122)
        return parse_connectedBot(reader)
    }

}

public extension Api.Dialog {
    /// dialog như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_dialog_l122(_ reader: BufferReader) -> Api.Dialog? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: Api.Peer?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.Peer
    }
    var _3: Int32?
    _3 = reader.readInt32()
    var _4: Int32?
    _4 = reader.readInt32()
    var _5: Int32?
    _5 = reader.readInt32()
    var _6: Int32?
    _6 = reader.readInt32()
    var _7: Int32?
    _7 = reader.readInt32()
    var _8: Int32?
    _8 = reader.readInt32()
    var _9: Api.PeerNotifySettings?
    if let signature = reader.readInt32() {
        _9 = Api.parse(reader, signature: signature) as? Api.PeerNotifySettings
    }
    var _10: Int32?
    if Int(_1!) & Int(1 << 0) != 0 {_10 = reader.readInt32() }
    var _11: Api.DraftMessage?
    if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
        _11 = Api.parse(reader, signature: signature) as? Api.DraftMessage
    } }
    var _12: Int32?
    if Int(_1!) & Int(1 << 4) != 0 {_12 = reader.readInt32() }
    var _13: Int32?
    if Int(_1!) & Int(1 << 5) != 0 {_13 = reader.readInt32() }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
    let _c6 = _6 != nil
    let _c7 = _7 != nil
    let _c8 = _8 != nil
    let _c9 = _9 != nil
    let _c10 = (Int(_1!) & Int(1 << 0) == 0) || _10 != nil
    let _c11 = (Int(_1!) & Int(1 << 1) == 0) || _11 != nil
    let _c12 = (Int(_1!) & Int(1 << 4) == 0) || _12 != nil
    let _c13 = (Int(_1!) & Int(1 << 5) == 0) || _13 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 && _c12 && _c13 {
            return Api.Dialog.dialog(Cons_dialog(flags: _1!, peer: _2!, topMessage: _3!, readInboxMaxId: _4!, readOutboxMaxId: _5!, unreadCount: _6!, unreadMentionsCount: _7!, unreadReactionsCount: _8!, unreadPollVotesCount: 0, notifySettings: _9!, pts: _10, draft: _11, folderId: _12, ttlPeriod: _13))
        } else {
            return nil
        }
    }

}

public extension Api.DraftMessage {
    /// draftMessage như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_draftMessage_l122(_ reader: BufferReader) -> Api.DraftMessage? {
        MxApiCompat.note(.l122)
        return parse_draftMessage(reader)
    }

}

public extension Api.ForumTopic {
    /// forumTopic như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_forumTopic_l122(_ reader: BufferReader) -> Api.ForumTopic? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Int32?
    _3 = reader.readInt32()
    var _4: Api.Peer?
    if let signature = reader.readInt32() {
        _4 = Api.parse(reader, signature: signature) as? Api.Peer
    }
    var _5: String?
    _5 = parseString(reader)
    var _6: Int32?
    _6 = reader.readInt32()
    var _7: Int64?
    if Int(_1!) & Int(1 << 0) != 0 {_7 = reader.readInt64() }
    var _8: Int32?
    _8 = reader.readInt32()
    var _9: Int32?
    _9 = reader.readInt32()
    var _10: Int32?
    _10 = reader.readInt32()
    var _11: Int32?
    _11 = reader.readInt32()
    var _12: Int32?
    _12 = reader.readInt32()
    var _13: Int32?
    _13 = reader.readInt32()
    var _14: Api.Peer?
    if let signature = reader.readInt32() {
        _14 = Api.parse(reader, signature: signature) as? Api.Peer
    }
    var _15: Api.PeerNotifySettings?
    if let signature = reader.readInt32() {
        _15 = Api.parse(reader, signature: signature) as? Api.PeerNotifySettings
    }
    var _16: Api.DraftMessage?
    if Int(_1!) & Int(1 << 4) != 0 {if let signature = reader.readInt32() {
        _16 = Api.parse(reader, signature: signature) as? Api.DraftMessage
    } }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
    let _c6 = _6 != nil
    let _c7 = (Int(_1!) & Int(1 << 0) == 0) || _7 != nil
    let _c8 = _8 != nil
    let _c9 = _9 != nil
    let _c10 = _10 != nil
    let _c11 = _11 != nil
    let _c12 = _12 != nil
    let _c13 = _13 != nil
    let _c14 = _14 != nil
    let _c15 = _15 != nil
    let _c16 = (Int(_1!) & Int(1 << 4) == 0) || _16 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 && _c12 && _c13 && _c14 && _c15 && _c16 {
            return Api.ForumTopic.forumTopic(Cons_forumTopic(flags: _1!, id: _2!, date: _3!, peer: _4!, title: _5!, iconColor: _6!, iconEmojiId: _7, topMessage: _8!, readInboxMaxId: _9!, readOutboxMaxId: _10!, unreadCount: _11!, unreadMentionsCount: _12!, unreadReactionsCount: _13!, unreadPollVotesCount: 0, fromId: _14!, notifySettings: _15!, draft: _16))
        } else {
            return nil
        }
    }

}

public extension Api.InputMedia {
    /// inputMediaPhoto như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputMediaPhoto_l122(_ reader: BufferReader) -> Api.InputMedia? {
        MxApiCompat.note(.l122)
        return parse_inputMediaPhoto(reader)
    }

    /// inputMediaPoll như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputMediaPoll_l122(_ reader: BufferReader) -> Api.InputMedia? {
        MxApiCompat.note(.l122)
        return parse_inputMediaPoll(reader)
    }

    /// inputMediaUploadedPhoto như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputMediaUploadedPhoto_l122(_ reader: BufferReader) -> Api.InputMedia? {
        MxApiCompat.note(.l122)
        return parse_inputMediaUploadedPhoto(reader)
    }

}

public extension Api.InputReplyTo {
    /// inputReplyToMessage như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputReplyToMessage_l122(_ reader: BufferReader) -> Api.InputReplyTo? {
        MxApiCompat.note(.l122)
        return parse_inputReplyToMessage(reader)
    }

}

public extension Api.InputStorePaymentPurpose {
    /// inputStorePaymentAuthCode như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_inputStorePaymentAuthCode_l122(_ reader: BufferReader) -> Api.InputStorePaymentPurpose? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: String?
    _2 = parseString(reader)
    var _3: String?
    _3 = parseString(reader)
    var _4: String?
    _4 = parseString(reader)
    var _5: Int64?
    _5 = reader.readInt64()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 {
            return Api.InputStorePaymentPurpose.inputStorePaymentAuthCode(Cons_inputStorePaymentAuthCode(flags: _1!, phoneNumber: _2!, phoneCodeHash: _3!, premiumDays: 0, currency: _4!, amount: _5!))
        } else {
            return nil
        }
    }

}

public extension Api.KeyboardButton {
    /// inputKeyboardButtonRequestPeer như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputKeyboardButtonRequestPeer_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_inputKeyboardButtonRequestPeer(reader)
    }

    /// inputKeyboardButtonUrlAuth như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_inputKeyboardButtonUrlAuth_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_inputKeyboardButtonUrlAuth(reader)
    }

    /// inputKeyboardButtonUserProfile như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_inputKeyboardButtonUserProfile_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: Api.InputUser?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.InputUser
    }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.inputKeyboardButtonUserProfile(Cons_inputKeyboardButtonUserProfile(flags: 0, style: nil, text: _1!, userId: _2!))
        } else {
            return nil
        }
    }

    /// keyboardButton như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButton_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    let _c1 = _1 != nil
        if _c1 {
            return Api.KeyboardButton.keyboardButton(Cons_keyboardButton(flags: 0, style: nil, text: _1!))
        } else {
            return nil
        }
    }

    /// keyboardButtonBuy như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonBuy_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    let _c1 = _1 != nil
        if _c1 {
            return Api.KeyboardButton.keyboardButtonBuy(Cons_keyboardButtonBuy(flags: 0, style: nil, text: _1!))
        } else {
            return nil
        }
    }

    /// keyboardButtonCallback như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_keyboardButtonCallback_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_keyboardButtonCallback(reader)
    }

    /// keyboardButtonCopy như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonCopy_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: String?
    _2 = parseString(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.keyboardButtonCopy(Cons_keyboardButtonCopy(flags: 0, style: nil, text: _1!, copyText: _2!))
        } else {
            return nil
        }
    }

    /// keyboardButtonGame như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonGame_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    let _c1 = _1 != nil
        if _c1 {
            return Api.KeyboardButton.keyboardButtonGame(Cons_keyboardButtonGame(flags: 0, style: nil, text: _1!))
        } else {
            return nil
        }
    }

    /// keyboardButtonRequestGeoLocation như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonRequestGeoLocation_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    let _c1 = _1 != nil
        if _c1 {
            return Api.KeyboardButton.keyboardButtonRequestGeoLocation(Cons_keyboardButtonRequestGeoLocation(flags: 0, style: nil, text: _1!))
        } else {
            return nil
        }
    }

    /// keyboardButtonRequestPeer như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonRequestPeer_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Api.RequestPeerType?
    if let signature = reader.readInt32() {
        _3 = Api.parse(reader, signature: signature) as? Api.RequestPeerType
    }
    var _4: Int32?
    _4 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
        if _c1 && _c2 && _c3 && _c4 {
            return Api.KeyboardButton.keyboardButtonRequestPeer(Cons_keyboardButtonRequestPeer(flags: 0, style: nil, text: _1!, buttonId: _2!, peerType: _3!, maxQuantity: _4!))
        } else {
            return nil
        }
    }

    /// keyboardButtonRequestPhone như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonRequestPhone_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    let _c1 = _1 != nil
        if _c1 {
            return Api.KeyboardButton.keyboardButtonRequestPhone(Cons_keyboardButtonRequestPhone(flags: 0, style: nil, text: _1!))
        } else {
            return nil
        }
    }

    /// keyboardButtonRequestPoll như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_keyboardButtonRequestPoll_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_keyboardButtonRequestPoll(reader)
    }

    /// keyboardButtonSimpleWebView như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonSimpleWebView_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: String?
    _2 = parseString(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.keyboardButtonSimpleWebView(Cons_keyboardButtonSimpleWebView(flags: 0, style: nil, text: _1!, url: _2!))
        } else {
            return nil
        }
    }

    /// keyboardButtonSwitchInline như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_keyboardButtonSwitchInline_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_keyboardButtonSwitchInline(reader)
    }

    /// keyboardButtonUrl như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonUrl_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: String?
    _2 = parseString(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.keyboardButtonUrl(Cons_keyboardButtonUrl(flags: 0, style: nil, text: _1!, url: _2!))
        } else {
            return nil
        }
    }

    /// keyboardButtonUrlAuth như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_keyboardButtonUrlAuth_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
        return parse_keyboardButtonUrlAuth(reader)
    }

    /// keyboardButtonUserProfile như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonUserProfile_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: Int64?
    _2 = reader.readInt64()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.keyboardButtonUserProfile(Cons_keyboardButtonUserProfile(flags: 0, style: nil, text: _1!, userId: _2!))
        } else {
            return nil
        }
    }

    /// keyboardButtonWebView như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_keyboardButtonWebView_l122(_ reader: BufferReader) -> Api.KeyboardButton? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: String?
    _2 = parseString(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.KeyboardButton.keyboardButtonWebView(Cons_keyboardButtonWebView(flags: 0, style: nil, text: _1!, url: _2!))
        } else {
            return nil
        }
    }

}

public extension Api.Message {
    /// message như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_message_l122(_ reader: BufferReader) -> Api.Message? {
        MxApiCompat.note(.l122)
        return parse_message(reader)
    }

}

public extension Api.MessageAction {
    /// messageActionStarGift như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_messageActionStarGift_l122(_ reader: BufferReader) -> Api.MessageAction? {
        MxApiCompat.note(.l122)
        return parse_messageActionStarGift(reader)
    }

    /// messageActionStarGiftUnique như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_messageActionStarGiftUnique_l122(_ reader: BufferReader) -> Api.MessageAction? {
        MxApiCompat.note(.l122)
        return parse_messageActionStarGiftUnique(reader)
    }

}

public extension Api.MessageMedia {
    /// messageMediaDice như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_messageMediaDice_l122(_ reader: BufferReader) -> Api.MessageMedia? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: String?
    _2 = parseString(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.MessageMedia.messageMediaDice(Cons_messageMediaDice(flags: 0, value: _1!, emoticon: _2!, gameOutcome: nil))
        } else {
            return nil
        }
    }

    /// messageMediaPhoto như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_messageMediaPhoto_l122(_ reader: BufferReader) -> Api.MessageMedia? {
        MxApiCompat.note(.l122)
        return parse_messageMediaPhoto(reader)
    }

    /// messageMediaPoll như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_messageMediaPoll_l122(_ reader: BufferReader) -> Api.MessageMedia? {
        MxApiCompat.note(.l122)
    var _1: Api.Poll?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.Poll
    }
    var _2: Api.PollResults?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.PollResults
    }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.MessageMedia.messageMediaPoll(Cons_messageMediaPoll(flags: 0, poll: _1!, results: _2!, attachedMedia: nil))
        } else {
            return nil
        }
    }

}

public extension Api.MessageReplyHeader {
    /// messageReplyHeader như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_messageReplyHeader_l122(_ reader: BufferReader) -> Api.MessageReplyHeader? {
        MxApiCompat.note(.l122)
        return parse_messageReplyHeader(reader)
    }

}

public extension Api.PageBlock {
    /// pageBlockOrderedList như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_pageBlockOrderedList_l122(_ reader: BufferReader) -> Api.PageBlock? {
        MxApiCompat.note(.l122)
    var _1: [Api.PageListOrderedItem]?
    if let _ = reader.readInt32() {
        _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PageListOrderedItem.self)
    }
    let _c1 = _1 != nil
        if _c1 {
            return Api.PageBlock.pageBlockOrderedList(Cons_pageBlockOrderedList(flags: 0, items: _1!, start: nil, type: nil))
        } else {
            return nil
        }
    }

}

public extension Api.PageListItem {
    /// pageListItemBlocks như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_pageListItemBlocks_l122(_ reader: BufferReader) -> Api.PageListItem? {
        MxApiCompat.note(.l122)
    var _1: [Api.PageBlock]?
    if let _ = reader.readInt32() {
        _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PageBlock.self)
    }
    let _c1 = _1 != nil
        if _c1 {
            return Api.PageListItem.pageListItemBlocks(Cons_pageListItemBlocks(flags: 0, blocks: _1!))
        } else {
            return nil
        }
    }

    /// pageListItemText như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_pageListItemText_l122(_ reader: BufferReader) -> Api.PageListItem? {
        MxApiCompat.note(.l122)
    var _1: Api.RichText?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.RichText
    }
    let _c1 = _1 != nil
        if _c1 {
            return Api.PageListItem.pageListItemText(Cons_pageListItemText(flags: 0, text: _1!))
        } else {
            return nil
        }
    }

}

public extension Api.PageListOrderedItem {
    /// pageListOrderedItemBlocks như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_pageListOrderedItemBlocks_l122(_ reader: BufferReader) -> Api.PageListOrderedItem? {
        MxApiCompat.note(.l122)
        return parse_pageListOrderedItemBlocks(reader)
    }

    /// pageListOrderedItemText như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_pageListOrderedItemText_l122(_ reader: BufferReader) -> Api.PageListOrderedItem? {
        MxApiCompat.note(.l122)
        return parse_pageListOrderedItemText(reader)
    }

}

public extension Api.Poll {
    /// poll như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_poll_l122(_ reader: BufferReader) -> Api.Poll? {
        MxApiCompat.note(.l122)
    var _1: Int64?
    _1 = reader.readInt64()
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Api.TextWithEntities?
    if let signature = reader.readInt32() {
        _3 = Api.parse(reader, signature: signature) as? Api.TextWithEntities
    }
    var _4: [Api.PollAnswer]?
    if let _ = reader.readInt32() {
        _4 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PollAnswer.self)
    }
    var _5: Int32?
    if Int(_2!) & Int(1 << 4) != 0 {_5 = reader.readInt32() }
    var _6: Int32?
    if Int(_2!) & Int(1 << 5) != 0 {_6 = reader.readInt32() }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = (Int(_2!) & Int(1 << 4) == 0) || _5 != nil
    let _c6 = (Int(_2!) & Int(1 << 5) == 0) || _6 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 {
            return Api.Poll.poll(Cons_poll(id: _1!, flags: _2!, question: _3!, answers: _4!, closePeriod: _5, closeDate: _6, countriesIso2: nil, hash: 0))
        } else {
            return nil
        }
    }

}

public extension Api.PollAnswer {
    /// pollAnswer như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_pollAnswer_l122(_ reader: BufferReader) -> Api.PollAnswer? {
        MxApiCompat.note(.l122)
    var _1: Api.TextWithEntities?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.TextWithEntities
    }
    var _2: Buffer?
    _2 = parseBytes(reader)
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.PollAnswer.pollAnswer(Cons_pollAnswer(flags: 0, text: _1!, option: _2!, media: nil, addedBy: nil, date: nil))
        } else {
            return nil
        }
    }

}

public extension Api.PollAnswerVoters {
    /// pollAnswerVoters như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_pollAnswerVoters_l122(_ reader: BufferReader) -> Api.PollAnswerVoters? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: Buffer?
    _2 = parseBytes(reader)
    var _3: Int32?
    _3 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
        if _c1 && _c2 && _c3 {
            return Api.PollAnswerVoters.pollAnswerVoters(Cons_pollAnswerVoters(flags: _1!, option: _2!, voters: _3!, recentVoters: nil))
        } else {
            return nil
        }
    }

}

public extension Api.PollResults {
    /// pollResults như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_pollResults_l122(_ reader: BufferReader) -> Api.PollResults? {
        MxApiCompat.note(.l122)
        return parse_pollResults(reader)
    }

}

public extension Api.ReactionsNotifySettings {
    /// reactionsNotifySettings như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_reactionsNotifySettings_l122(_ reader: BufferReader) -> Api.ReactionsNotifySettings? {
        MxApiCompat.note(.l122)
        return parse_reactionsNotifySettings(reader)
    }

}

public extension Api.SavedStarGift {
    /// savedStarGift như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_savedStarGift_l122(_ reader: BufferReader) -> Api.SavedStarGift? {
        MxApiCompat.note(.l122)
        return parse_savedStarGift(reader)
    }

}

public extension Api.StarGift {
    /// starGift như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_starGift_l122(_ reader: BufferReader) -> Api.StarGift? {
        MxApiCompat.note(.l122)
        return parse_starGift(reader)
    }

    /// starGiftUnique như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_starGiftUnique_l122(_ reader: BufferReader) -> Api.StarGift? {
        MxApiCompat.note(.l122)
        return parse_starGiftUnique(reader)
    }

}

public extension Api.StarGiftAttribute {
    /// starGiftAttributeBackdrop như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_starGiftAttributeBackdrop_l122(_ reader: BufferReader) -> Api.StarGiftAttribute? {
        MxApiCompat.note(.l122)
        return parse_starGiftAttributeBackdrop(reader)
    }

    /// starGiftAttributeModel như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_starGiftAttributeModel_l122(_ reader: BufferReader) -> Api.StarGiftAttribute? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: Api.Document?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.Document
    }
    var _3: Int32?
    _3 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
        if _c1 && _c2 && _c3 {
            return Api.StarGiftAttribute.starGiftAttributeModel(Cons_starGiftAttributeModel(flags: 0, name: _1!, document: _2!, rarity: Api.StarGiftAttributeRarity.starGiftAttributeRarity(Api.StarGiftAttributeRarity.Cons_starGiftAttributeRarity(permille: 0))))
        } else {
            return nil
        }
    }

    /// starGiftAttributePattern như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_starGiftAttributePattern_l122(_ reader: BufferReader) -> Api.StarGiftAttribute? {
        MxApiCompat.note(.l122)
        return parse_starGiftAttributePattern(reader)
    }

}

public extension Api.StarGiftAuctionAcquiredGift {
    /// starGiftAuctionAcquiredGift như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_starGiftAuctionAcquiredGift_l122(_ reader: BufferReader) -> Api.StarGiftAuctionAcquiredGift? {
        MxApiCompat.note(.l122)
        return parse_starGiftAuctionAcquiredGift(reader)
    }

}

public extension Api.StarGiftAuctionState {
    /// starGiftAuctionState như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_starGiftAuctionState_l122(_ reader: BufferReader) -> Api.StarGiftAuctionState? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Int32?
    _3 = reader.readInt32()
    var _4: Int64?
    _4 = reader.readInt64()
    var _5: [Api.AuctionBidLevel]?
    if let _ = reader.readInt32() {
        _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.AuctionBidLevel.self)
    }
    var _6: [Int64]?
    if let _ = reader.readInt32() {
        _6 = Api.parseVector(reader, elementSignature: 570911930, elementType: Int64.self)
    }
    var _7: Int32?
    _7 = reader.readInt32()
    var _8: Int32?
    _8 = reader.readInt32()
    var _9: Int32?
    _9 = reader.readInt32()
    var _10: Int32?
    _10 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
    let _c6 = _6 != nil
    let _c7 = _7 != nil
    let _c8 = _8 != nil
    let _c9 = _9 != nil
    let _c10 = _10 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 {
            return Api.StarGiftAuctionState.starGiftAuctionState(Cons_starGiftAuctionState(version: _1!, startDate: _2!, endDate: _3!, minBidAmount: _4!, bidLevels: _5!, topBidders: _6!, nextRoundAt: _7!, lastGiftNum: 0, giftsLeft: _8!, currentRound: _9!, totalRounds: _10!, rounds: []))
        } else {
            return nil
        }
    }

    /// starGiftAuctionStateFinished như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_starGiftAuctionStateFinished_l122(_ reader: BufferReader) -> Api.StarGiftAuctionState? {
        MxApiCompat.note(.l122)
    var _1: Int32?
    _1 = reader.readInt32()
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Int64?
    _3 = reader.readInt64()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
        if _c1 && _c2 && _c3 {
            return Api.StarGiftAuctionState.starGiftAuctionStateFinished(Cons_starGiftAuctionStateFinished(flags: 0, startDate: _1!, endDate: _2!, averagePrice: _3!, listedCount: nil, fragmentListedCount: nil, fragmentListedUrl: nil))
        } else {
            return nil
        }
    }

}

public extension Api.StoryItem {
    /// storyItem như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_storyItem_l122(_ reader: BufferReader) -> Api.StoryItem? {
        MxApiCompat.note(.l122)
        return parse_storyItem(reader)
    }

}

public extension Api.Update {
    /// updateBotChatInviteRequester như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_updateBotChatInviteRequester_l122(_ reader: BufferReader) -> Api.Update? {
        MxApiCompat.note(.l122)
    var _1: Api.Peer?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.Peer
    }
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Int64?
    _3 = reader.readInt64()
    var _4: String?
    _4 = parseString(reader)
    var _5: Api.ExportedChatInvite?
    if let signature = reader.readInt32() {
        _5 = Api.parse(reader, signature: signature) as? Api.ExportedChatInvite
    }
    var _6: Int32?
    _6 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
    let _c6 = _6 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 {
            return Api.Update.updateBotChatInviteRequester(Cons_updateBotChatInviteRequester(flags: 0, peer: _1!, date: _2!, userId: _3!, about: _4!, invite: _5!, qts: _6!, queryId: nil))
        } else {
            return nil
        }
    }

    /// updateMessagePoll như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_updateMessagePoll_l122(_ reader: BufferReader) -> Api.Update? {
        MxApiCompat.note(.l122)
        return parse_updateMessagePoll(reader)
    }

    /// updateMessagePollVote như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_updateMessagePollVote_l122(_ reader: BufferReader) -> Api.Update? {
        MxApiCompat.note(.l122)
    var _1: Int64?
    _1 = reader.readInt64()
    var _2: Api.Peer?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.Peer
    }
    var _3: [Buffer]?
    if let _ = reader.readInt32() {
        _3 = Api.parseVector(reader, elementSignature: -1255641564, elementType: Buffer.self)
    }
    var _4: Int32?
    _4 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
        if _c1 && _c2 && _c3 && _c4 {
            return Api.Update.updateMessagePollVote(Cons_updateMessagePollVote(pollId: _1!, peer: _2!, options: _3!, positions: [], qts: _4!))
        } else {
            return nil
        }
    }

}

public extension Api.UrlAuthResult {
    /// urlAuthResultAccepted như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_urlAuthResultAccepted_l122(_ reader: BufferReader) -> Api.UrlAuthResult? {
        MxApiCompat.note(.l122)
        return parse_urlAuthResultAccepted(reader)
    }

    /// urlAuthResultRequest như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_urlAuthResultRequest_l122(_ reader: BufferReader) -> Api.UrlAuthResult? {
        MxApiCompat.note(.l122)
        return parse_urlAuthResultRequest(reader)
    }

}

public extension Api.UserFull {
    /// userFull như 12.2 định nghĩa. Mọi trường 12.9.2 thêm vào đều nằm
    /// sau bit canh mà máy chủ 12.2 không bật, nên parser hiện tại đọc
    /// đúng payload cũ; vỏ bọc này chỉ ghi nhận lớp mà app chủ nói.
    static func parse_userFull_l122(_ reader: BufferReader) -> Api.UserFull? {
        MxApiCompat.note(.l122)
        return parse_userFull(reader)
    }

}

public extension Api.WebPageAttribute {
    /// webPageAttributeStarGiftAuction như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_webPageAttributeStarGiftAuction_l122(_ reader: BufferReader) -> Api.WebPageAttribute? {
        MxApiCompat.note(.l122)
    var _1: Api.StarGift?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.StarGift
    }
    var _2: Int32?
    _2 = reader.readInt32()
    var _3: Int32?
    _3 = reader.readInt32()
    var _4: Int32?
    _4 = reader.readInt32()
    var _5: Int32?
    _5 = reader.readInt32()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 {
            return Api.WebPageAttribute.webPageAttributeStarGiftAuction(Cons_webPageAttributeStarGiftAuction(gift: _1!, endDate: _2!))
        } else {
            return nil
        }
    }

}

public extension Api.auth.SentCode {
    /// sentCodePaymentRequired như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_sentCodePaymentRequired_l122(_ reader: BufferReader) -> Api.auth.SentCode? {
        MxApiCompat.note(.l122)
    var _1: String?
    _1 = parseString(reader)
    var _2: String?
    _2 = parseString(reader)
    var _3: String?
    _3 = parseString(reader)
    var _4: String?
    _4 = parseString(reader)
    var _5: String?
    _5 = parseString(reader)
    var _6: Int64?
    _6 = reader.readInt64()
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
    let _c6 = _6 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 {
            return Api.auth.SentCode.sentCodePaymentRequired(Cons_sentCodePaymentRequired(storeProduct: _1!, phoneCodeHash: _2!, supportEmailAddress: _3!, supportEmailSubject: _4!, premiumDays: 0, currency: _5!, amount: _6!))
        } else {
            return nil
        }
    }

}

public extension Api.payments.StarGiftActiveAuctions {
    /// starGiftActiveAuctions như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_starGiftActiveAuctions_l122(_ reader: BufferReader) -> Api.payments.StarGiftActiveAuctions? {
        MxApiCompat.note(.l122)
    var _1: [Api.StarGiftActiveAuctionState]?
    if let _ = reader.readInt32() {
        _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.StarGiftActiveAuctionState.self)
    }
    var _2: [Api.User]?
    if let _ = reader.readInt32() {
        _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
    }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
        if _c1 && _c2 {
            return Api.payments.StarGiftActiveAuctions.starGiftActiveAuctions(Cons_starGiftActiveAuctions(auctions: _1!, users: _2!, chats: []))
        } else {
            return nil
        }
    }

}

public extension Api.payments.StarGiftAuctionState {
    /// starGiftAuctionState như 12.2 định nghĩa — bố cục khác thật, không dùng lại
    /// parser hiện tại được.
    static func parse_starGiftAuctionState_l122(_ reader: BufferReader) -> Api.payments.StarGiftAuctionState? {
        MxApiCompat.note(.l122)
    var _1: Api.StarGift?
    if let signature = reader.readInt32() {
        _1 = Api.parse(reader, signature: signature) as? Api.StarGift
    }
    var _2: Api.StarGiftAuctionState?
    if let signature = reader.readInt32() {
        _2 = Api.parse(reader, signature: signature) as? Api.StarGiftAuctionState
    }
    var _3: Api.StarGiftAuctionUserState?
    if let signature = reader.readInt32() {
        _3 = Api.parse(reader, signature: signature) as? Api.StarGiftAuctionUserState
    }
    var _4: Int32?
    _4 = reader.readInt32()
    var _5: [Api.User]?
    if let _ = reader.readInt32() {
        _5 = Api.parseVector(reader, elementSignature: 0, elementType: Api.User.self)
    }
    let _c1 = _1 != nil
    let _c2 = _2 != nil
    let _c3 = _3 != nil
    let _c4 = _4 != nil
    let _c5 = _5 != nil
        if _c1 && _c2 && _c3 && _c4 && _c5 {
            return Api.payments.StarGiftAuctionState.starGiftAuctionState(Cons_starGiftAuctionState(gift: _1!, state: _2!, userState: _3!, timeout: _4!, users: _5!, chats: []))
        } else {
            return nil
        }
    }

}
