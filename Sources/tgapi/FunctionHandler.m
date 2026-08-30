#import "Headers.h"
#import "GhostExceptions.h"

NSData *boolTrue() {
    uint8_t bytes[] = {0xB5, 0x75, 0x72, 0x99}; // boolTrue#997275b5
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

NSData *boolFalse() {
    uint8_t bytes[] = {0x37, 0x97, 0x79, 0xBC}; // boolFalse#bc799737
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}

// Handlers
void handleOnlineStatus(MTRequest *request, NSData *payload) {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults boolForKey:kGhostModeEnabled]) {
		mxDiag("updateStatus IGNORED — Ghost Mode is off");
		return;
	}

	if (payload.length < 4) return;

	NSData *isOfflineData = [payload subdataWithRange:NSMakeRange(payload.length - 4, 4)];
	uint32_t isOffline = 0;
	[isOfflineData getBytes:&isOffline length:4];

	BOOL wantsHidden = [defaults boolForKey:kDisableOnlineStatus];
	// 3162085175 == 0xBC799737 == boolFalse, i.e. offline:false — the client is
	// announcing that it just came online.
	BOOL goingOnline = (isOffline == 3162085175);

	mxDiag("updateStatus raw=0x%08X goingOnline=%d hideEnabled=%d len=%lu",
	         isOffline, goingOnline, wantsHidden, (unsigned long)payload.length);

	if (goingOnline && wantsHidden) {
		request.fakeData = boolTrue();
		mxDiag("updateStatus BLOCKED");
	}
}

// Walks an InputPeer, advancing *offset past it.
//
// outUserId, when non-NULL, receives the user_id for inputPeerUser and 0 for
// every other peer type. Ghost Exceptions only cover user peers (see
// GhostExceptions.h), so group/channel constructors deliberately report 0
// rather than their chat_id/channel_id.
void read_Input_Peer(NSData *data, int *offset, int64_t *outUserId) {
	#define InputPeerEmpty 2134579434
	#define InputPeerSelf 2107670217
	#define InputPeerChat 900291769
	#define InputPeerUser -571955892
	#define InputPeerChannel 666680316
	#define InputPeerUserFromChannel -1468331492
	#define InputPeerChannelFromMessage -1121318848

	if (outUserId) *outUserId = 0;

	// A truncated payload must not read past the buffer.
	if (*offset < 0 || (NSUInteger)(*offset) + 4 > data.length) return;

	int32_t peerConstructorID = 0;
	[data getBytes:&peerConstructorID range:NSMakeRange(*offset, 4)];
	*offset += 4;

	switch (peerConstructorID) {
		case InputPeerEmpty:
		    return;
		case InputPeerSelf:
		    return;
		case InputPeerChat:
		    *offset += 8;
			return;
		case InputPeerUser:
		    // inputPeerUser#dde8a54c user_id:long access_hash:long
		    if (outUserId && (NSUInteger)(*offset) + 8 <= data.length) {
		        [data getBytes:outUserId range:NSMakeRange(*offset, 8)];
		    }
		    *offset += 16;
			return;
		case InputPeerChannel:
		    *offset += 16;
			return;
		case InputPeerUserFromChannel:
		    // The nested peer is the channel the user was seen in, not the
		    // target — discard whatever the recursive call reported.
		    read_Input_Peer(data, offset, NULL);
		    *offset += 12;
			return;
		case InputPeerChannelFromMessage:
		    read_Input_Peer(data, offset, NULL);
		    *offset += 12;
			return;
		default :
		    return;
	}
}

// YES when this peer is on the Ghost Exceptions list and must therefore see
// your real activity.
static BOOL isGhostException(int64_t userId) {
	BOOL hit = userId != 0 && [MxGhostExceptions containsPeerId:userId];
	if (hit) {
		mxDiag("ghost-exception HIT peer=%lld — letting real activity through", userId);
	}
	return hit;
}

void handleSetTyping(MTRequest *request, NSData *payload) {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kGhostModeEnabled]) return;
	
	int offset = 0;
	offset += 4; // Skip First 4 Bytes of constructor id;
	int32_t flags = 0;
	[payload getBytes:&flags range:NSMakeRange(offset, 4)];
	offset += 4;

	int64_t peerUserId = 0;
	read_Input_Peer(payload, &offset, &peerUserId); // Read Peer

	mxDiag("setTyping peer=%lld", peerUserId);

	// Ghost Exception: this peer keeps seeing your real typing indicators.
	if (isGhostException(peerUserId)) return;

	if ((flags & (1 << 0)) != 0) {
		offset += 4; // Topic id
	}
	
	int32_t actionID = 0;
	[payload getBytes:&actionID range:NSMakeRange(offset, 4)];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	bool shouldBlockAction = false;
	
	//customLog(@"Handle Set Typing action : %d actionData:%@", actionID, [payload description]);
	switch (actionID) {
		case kActionIDTyping:
		shouldBlockAction = [defaults boolForKey:kDisableTypingStatus];
		  break;
		case kActionIDRecordingVideo:
		  shouldBlockAction = [defaults boolForKey:kDisableRecordingVideoStatus];
		  break;
		case kActionIDUploadingVideo:
		  shouldBlockAction = [defaults boolForKey:kDisableUploadingVideoStatus];
		  break;
		case kActionIDRecordingAudio:
		  shouldBlockAction = [defaults boolForKey:kDisableRecordingVoiceStatus];
		  break;
		case kActionIDUploadingVoice:
		  shouldBlockAction = [defaults boolForKey:kDisableUploadingVoiceStatus];
		  break;
		case kActionIDUploadingPhoto:
		  shouldBlockAction = [defaults boolForKey:kDisableUploadingPhotoStatus];
		  break;
		case kActionIDUploadingFile:
		  shouldBlockAction = [defaults boolForKey:kDisableUploadingFileStatus];
		  break;
		case kActionIDChoosingLocation:
		  shouldBlockAction = [defaults boolForKey:kDisableChoosingLocationStatus];
		  break;
		case kActionIDChoosingContact:
		  shouldBlockAction = [defaults boolForKey:kDisableChoosingContactStatus];
		  break;
		case kActionIDPlayingGame:
		  shouldBlockAction = [defaults boolForKey:kDisablePlayingGameStatus];
		  break;
		case kActionIDRecordingRoundVideo:
		  shouldBlockAction = [defaults boolForKey:kDisableRecordingRoundVideoStatus];
		  break;
		case kActionIDUploadingRoundVideo:
		  shouldBlockAction = [defaults boolForKey:kDisableUploadingRoundVideoStatus];
		  break;
		case kActionIDSpeakingInGroupCall:
		  shouldBlockAction = [defaults boolForKey:kDisableSpeakingInGroupCallStatus];
		  break;
		case kActionIDReserverHistoryImport:
		  shouldBlockAction = [defaults boolForKey:@"reserverHistroyImport"];
		  break;
		case kActionIDChoosingSticker:
		  shouldBlockAction = [defaults boolForKey:kDisableChoosingStickerStatus];
		  break;
		case kActionIDEmojiInteraction:
		  shouldBlockAction = [defaults boolForKey:kDisableEmojiInteractionStatus];
		  break;
		case kActionIDEmojiAcknowledgement:
		  shouldBlockAction = [defaults boolForKey:kDisableEmojiAcknowledgementStatus];
		  break;
	}
	
	if (shouldBlockAction) {
		request.fakeData = boolTrue();
	}
}

void handleMessageReadReceipt(MTRequest *request, NSData *payload) {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kGhostModeEnabled]) return;

	// messages.readHistory#0e306d3a peer:InputPeer max_id:int
	// Ghost Exception: this peer keeps getting your real read receipts.
	int offset = 4; // skip constructor id
	int64_t peerUserId = 0;
	read_Input_Peer(payload, &offset, &peerUserId);
	mxDiag("readHistory peer=%lld", peerUserId);
	if (isGhostException(peerUserId)) return;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableMessageReadReceipt]) {
		
		 uint8_t header[] = {0x85, 0x91, 0xD1, 0x84}; // messages.affectedMessages#84d19185
		 int32_t pts = 0;
		 int32_t pts_count = 0;
		 
		 NSMutableData *data = [NSMutableData data];
		 [data appendBytes:&header length:sizeof(header)];
		 [data appendBytes:&pts length:sizeof(pts)];
		 [data appendBytes:&pts_count length:sizeof(pts_count)];
	
		request.fakeData = data;
	}
}

void handleStoriesReadReceipt(MTRequest *request, NSData *payload) {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kGhostModeEnabled]) return;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableStoriesReadReceipt]) {
		
		uint8_t vectorID[] = {0x15, 0xC4, 0xB5, 0x1C}; // vector#1cb5c415
		int32_t count = 0;  
		
		NSMutableData *data = [NSMutableData data];
		[data appendBytes:&vectorID length:sizeof(vectorID)];
		[data appendBytes:&count length:sizeof(count)];
	
		request.fakeData = data;
	}
}

void handleGetSponsoredMessages(MTRequest *request, NSData *payload) {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableAllAds]) {
		
		uint8_t header[] = {0x0F, 0X49, 0X39, 0X18}; // messages.sponsoredMessagesEmpty#1839490f
		request.fakeData = [NSData dataWithBytes:header length:sizeof(header)];
	}
}

void handleChannelsReadReceipt(MTRequest *request, NSData *payload) {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kGhostModeEnabled]) return;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableMessageReadReceipt]) {
		request.fakeData = boolTrue();
	}
}

void handleSendScreenshotNotification(MTRequest *request, NSData *payload) {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kDisableScreenshotNotification]) {
		request.fakeData = boolTrue();
	}
}

// Anti-Self-Destruct: intercept messages.readMessageContents
// This call tells the server a TTL/disappearing message was opened.
// Blocking it prevents the server from starting the deletion timer.
// The media can be viewed locally without triggering server-side expiry.
void handleReadMessageContents(MTRequest *request, NSData *payload) {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kAntiSelfDestruct]) {
		// Return a fake messages.affectedMessages with pts=0, pts_count=0
		// so the client thinks the request succeeded but nothing actually happens
		uint8_t header[] = {0x85, 0x91, 0xD1, 0x84}; // messages.affectedMessages#84d19185
		int32_t pts = 0;
		int32_t pts_count = 0;

		NSMutableData *data = [NSMutableData data];
		[data appendBytes:&header length:sizeof(header)];
		[data appendBytes:&pts length:sizeof(pts)];
		[data appendBytes:&pts_count length:sizeof(pts_count)];

		request.fakeData = data;
	}
}