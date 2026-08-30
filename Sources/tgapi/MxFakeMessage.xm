// ============================================================
// Mx — Fake Message (local-only)
//
// What it does
//   Type a message but do not send it. Long-press the send button and an extra
//   entry appears: "Send as the other person". The text is removed from the
//   input field and drawn as an incoming bubble at the bottom of the
//   conversation. Nothing is sent, nothing leaves the device, and the other
//   side never sees it — this is a purely local overlay.
//
//   To remove them: long-press the "Ask a Question" row in Telegram Settings to
//   open the Mx menu, then tap "Delete fake messages".
//
// Why an overlay and not a real message
//   Injecting a fabricated message into Telegram's own message store means the
//   fake ends up in the local database, survives relaunches, and can only be
//   removed by a real delete — which is exactly the state a "delete fake
//   messages" button cannot get out of. Drawing the bubbles ourselves keeps the
//   fake entirely outside Telegram's state, so clearing it is a single call.
//
//   The trade-off is that the bubbles are pinned above the input panel rather
//   than living inside the scrolling history: they stay at the bottom of the
//   screen instead of scrolling away with the rest of the chat.
// ============================================================

#import "Headers.h"
#import "UI/Headers.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define MxFakeLoc(key) [MxLocalization localizedStringForKey:(key)]

// Per-peer store: { "<peerId>": [ { "text": ..., "date": ... }, ... ] }
static NSString *const kMxFakeMessagesStoreKey = @"MxFakeMessages";

static const NSInteger kMxFakeOverlayTag = 7781;
static const void *kMxFakeOverlayPeerKey = &kMxFakeOverlayPeerKey;

// ============================================================
// Store
// ============================================================

@interface MxFakeMessageStore : NSObject
+ (NSArray<NSDictionary *> *)messagesForPeer:(long long)peerId;
+ (void)addText:(NSString *)text forPeer:(long long)peerId;
+ (NSInteger)totalCount;
+ (void)removeAll;
@end

@implementation MxFakeMessageStore

+ (NSDictionary *)store {
  NSDictionary *raw =
      [[NSUserDefaults standardUserDefaults] objectForKey:kMxFakeMessagesStoreKey];
  return [raw isKindOfClass:[NSDictionary class]] ? raw : @{};
}

+ (void)setStore:(NSDictionary *)store {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  if (store.count == 0) {
    [defaults removeObjectForKey:kMxFakeMessagesStoreKey];
  } else {
    [defaults setObject:store forKey:kMxFakeMessagesStoreKey];
  }
  [defaults synchronize];
}

+ (NSArray<NSDictionary *> *)messagesForPeer:(long long)peerId {
  if (peerId == 0) return @[];
  NSArray *list = [self store][[@(peerId) stringValue]];
  return [list isKindOfClass:[NSArray class]] ? list : @[];
}

+ (void)addText:(NSString *)text forPeer:(long long)peerId {
  if (peerId == 0 || text.length == 0) return;

  NSString *key = [@(peerId) stringValue];
  NSMutableDictionary *store = [[self store] mutableCopy];
  NSMutableArray *list = [([store[key] isKindOfClass:[NSArray class]] ? store[key] : @[])
      mutableCopy];

  // Bounded on purpose: the overlay is pinned above the input panel, so an
  // unbounded list would eventually cover the whole conversation.
  [list addObject:@{
    @"text" : text,
    @"date" : @([[NSDate date] timeIntervalSince1970])
  }];
  while (list.count > 20) {
    [list removeObjectAtIndex:0];
  }

  store[key] = list;
  [self setStore:store];
}

+ (NSInteger)totalCount {
  NSInteger total = 0;
  for (NSArray *list in [self store].allValues) {
    if ([list isKindOfClass:[NSArray class]]) total += (NSInteger)list.count;
  }
  return total;
}

+ (void)removeAll {
  [self setStore:@{}];
}

@end

// ============================================================
// Overlay
// ============================================================

@interface MxFakeMessageOverlay : UIView
@property(nonatomic, assign) long long peerId;
- (void)reload;
@end

@implementation MxFakeMessageOverlay

- (instancetype)initWithPeerId:(long long)peerId {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    _peerId = peerId;
    self.tag = kMxFakeOverlayTag;
    self.backgroundColor = [UIColor clearColor];
    // Touches must reach the real chat underneath: the overlay is decoration,
    // not a control.
    self.userInteractionEnabled = NO;
    self.layer.zPosition = 500;
  }
  return self;
}

+ (UIColor *)bubbleColor {
  if (@available(iOS 13.0, *)) {
    return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *tc) {
      return tc.userInterfaceStyle == UIUserInterfaceStyleDark
                 ? [UIColor colorWithRed:0.16 green:0.17 blue:0.18 alpha:1.0]
                 : [UIColor whiteColor];
    }];
  }
  return [UIColor whiteColor];
}

/// Bubbles sit directly above the input panel. Its class name is the only stable
/// handle we have on it across Telegram builds and forks.
- (CGFloat)inputPanelTopInSuperview {
  UIView *host = self.superview;
  if (!host) return 0;

  CGFloat best = CGFLOAT_MAX;
  for (UIView *sub in host.subviews) {
    if (sub == self || sub.hidden || sub.alpha < 0.01) continue;
    NSString *cls = NSStringFromClass([sub class]);
    if (![cls containsString:@"InputPanel"] && ![cls containsString:@"InputContext"]) {
      continue;
    }
    if (sub.frame.size.height < 20) continue;
    best = MIN(best, sub.frame.origin.y);
  }

  if (best != CGFLOAT_MAX) return best;

  // No panel found — a channel without a composer, or a build that renames it.
  CGFloat bottomInset = 0;
  if (@available(iOS 11.0, *)) bottomInset = host.safeAreaInsets.bottom;
  return host.bounds.size.height - bottomInset - 8;
}

- (void)reload {
  for (UIView *sub in [self.subviews copy]) {
    [sub removeFromSuperview];
  }

  NSArray<NSDictionary *> *messages =
      [MxFakeMessageStore messagesForPeer:self.peerId];
  if (messages.count == 0) {
    self.hidden = YES;
    return;
  }
  self.hidden = NO;

  UIView *host = self.superview;
  if (!host) return;

  CGFloat hostWidth = host.bounds.size.width;
  CGFloat maxBubbleWidth = MAX(120.0, hostWidth * 0.72);
  CGFloat leading = 8.0;
  CGFloat spacing = 4.0;

  NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
  timeFormatter.dateStyle = NSDateFormatterNoStyle;
  timeFormatter.timeStyle = NSDateFormatterShortStyle;

  // Laid out bottom-up: the newest fake is nearest the input panel, which is
  // where a real newest message would be.
  CGFloat totalHeight = 0;
  NSMutableArray<UIView *> *bubbles = [NSMutableArray array];

  for (NSDictionary *entry in messages) {
    NSString *text = entry[@"text"];
    if (![text isKindOfClass:[NSString class]] || text.length == 0) continue;

    NSDate *date =
        [NSDate dateWithTimeIntervalSince1970:[entry[@"date"] doubleValue]];

    UIView *bubble = [[UIView alloc] init];
    bubble.backgroundColor = [MxFakeMessageOverlay bubbleColor];
    bubble.layer.cornerRadius = 16;
    bubble.layer.masksToBounds = YES;
    bubble.layer.shadowColor = [UIColor blackColor].CGColor;

    UILabel *body = [[UILabel alloc] init];
    body.text = text;
    body.numberOfLines = 0;
    body.font = [UIFont systemFontOfSize:17];
    if (@available(iOS 13.0, *)) {
      body.textColor = [UIColor labelColor];
    } else {
      body.textColor = [UIColor blackColor];
    }

    UILabel *time = [[UILabel alloc] init];
    time.text = [timeFormatter stringFromDate:date];
    time.font = [UIFont systemFontOfSize:11];
    if (@available(iOS 13.0, *)) {
      time.textColor = [UIColor secondaryLabelColor];
    } else {
      time.textColor = [UIColor grayColor];
    }
    [time sizeToFit];

    CGFloat hPad = 12.0;
    CGFloat vPad = 7.0;
    CGFloat timeGap = 6.0;
    CGFloat textMaxWidth = maxBubbleWidth - hPad * 2 - time.frame.size.width - timeGap;
    CGSize bodySize = [body sizeThatFits:CGSizeMake(textMaxWidth, CGFLOAT_MAX)];
    bodySize.width = MIN(bodySize.width, textMaxWidth);

    CGFloat bubbleWidth = bodySize.width + hPad * 2 + time.frame.size.width + timeGap;
    CGFloat bubbleHeight = MAX(bodySize.height + vPad * 2, 34.0);

    body.frame = CGRectMake(hPad, vPad, bodySize.width, bodySize.height);
    time.frame = CGRectMake(bubbleWidth - hPad - time.frame.size.width,
                            bubbleHeight - vPad - time.frame.size.height + 1,
                            time.frame.size.width, time.frame.size.height);

    [bubble addSubview:body];
    [bubble addSubview:time];
    bubble.frame = CGRectMake(leading, 0, bubbleWidth, bubbleHeight);

    [bubbles addObject:bubble];
    totalHeight += bubbleHeight + spacing;
  }

  if (bubbles.count == 0) {
    self.hidden = YES;
    return;
  }

  CGFloat panelTop = [self inputPanelTopInSuperview];
  CGFloat originY = MAX(0, panelTop - totalHeight - 2);
  self.frame = CGRectMake(0, originY, hostWidth, totalHeight);

  CGFloat y = 0;
  for (UIView *bubble in bubbles) {
    CGRect f = bubble.frame;
    f.origin.y = y;
    bubble.frame = f;
    [self addSubview:bubble];
    y += f.size.height + spacing;
  }
}

@end

// ============================================================
// Chat screen plumbing
// ============================================================

static long long mxPeerIdForChatController(UIViewController *controller) {
  if (!controller) return 0;
  @try {
    Class tlParser = NSClassFromString(@"TLParser");
    if (![tlParser respondsToSelector:@selector(getPeerIdFromNode:)]) return 0;
    NSNumber *peerId = [tlParser performSelector:@selector(getPeerIdFromNode:)
                                      withObject:controller];
    return peerId ? peerId.longLongValue : 0;
  } @catch (NSException *e) {
    return 0;
  }
}

/// The chat screen currently on top, found by walking up from any view inside it.
static UIViewController *mxEnclosingChatController(UIView *view) {
  UIResponder *responder = view;
  while (responder) {
    if ([responder isKindOfClass:[UIViewController class]]) {
      NSString *cls = NSStringFromClass([responder class]);
      if ([cls containsString:@"ChatController"]) {
        return (UIViewController *)responder;
      }
    }
    responder = responder.nextResponder;
  }
  return nil;
}

static MxFakeMessageOverlay *mxOverlayForController(UIViewController *controller,
                                                    BOOL create) {
  if (!controller.isViewLoaded) return nil;
  UIView *host = controller.view;

  MxFakeMessageOverlay *overlay =
      (MxFakeMessageOverlay *)[host viewWithTag:kMxFakeOverlayTag];
  if (overlay && [overlay isKindOfClass:[MxFakeMessageOverlay class]]) {
    return overlay;
  }
  if (!create) return nil;

  long long peerId = mxPeerIdForChatController(controller);
  if (peerId == 0) return nil;

  overlay = [[MxFakeMessageOverlay alloc] initWithPeerId:peerId];
  [host addSubview:overlay];
  return overlay;
}

static void mxRefreshOverlayForController(UIViewController *controller) {
  if (!controller) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    MxFakeMessageOverlay *overlay = mxOverlayForController(controller, YES);
    if (!overlay) return;
    [overlay.superview bringSubviewToFront:overlay];
    [overlay reload];
  });
}

// ============================================================
// Reading and clearing the composer
// ============================================================

static UITextView *mxFindComposerTextView(UIView *root, int depth) {
  if (!root || depth > 12) return nil;

  for (UIView *sub in root.subviews) {
    if ([sub isKindOfClass:[UITextView class]] && !sub.hidden && sub.alpha > 0.01) {
      return (UITextView *)sub;
    }
    UITextView *found = mxFindComposerTextView(sub, depth + 1);
    if (found) return found;
  }
  return nil;
}

/// The composer, searched inside the input panel rather than the whole screen so
/// a search bar or a caption field cannot be mistaken for it.
static UITextView *mxComposerTextView(UIViewController *controller) {
  if (!controller.isViewLoaded) return nil;

  for (UIView *sub in controller.view.subviews) {
    NSString *cls = NSStringFromClass([sub class]);
    if (![cls containsString:@"InputPanel"]) continue;
    UITextView *found = mxFindComposerTextView(sub, 0);
    if (found) return found;
  }
  return mxFindComposerTextView(controller.view, 0);
}

static void mxClearComposer(UITextView *textView) {
  if (!textView) return;

  textView.text = @"";
  if ([textView.delegate respondsToSelector:@selector(textViewDidChange:)]) {
    [textView.delegate textViewDidChange:textView];
  }
  // Telegram's own panel also watches for the notification; posting it keeps the
  // send button and the placeholder in step with the now-empty field.
  [[NSNotificationCenter defaultCenter]
      postNotificationName:UITextViewTextDidChangeNotification
                    object:textView];
}

// ============================================================
// Long-press on the send button
// ============================================================

static BOOL mxLabelIsSendButton(NSString *label) {
  if (label.length == 0) return NO;
  NSString *lower = [label lowercaseString];

  // Accessibility labels for the send button across the languages Mx ships.
  static NSSet *sendLabels = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    sendLabels = [NSSet setWithArray:@[
      @"send", @"send message", @"отправить", @"отправить сообщение",
      @"enviar", @"envoyer", @"invia", @"送信", @"发送", @"發送",
      @"إرسال", @"gửi"
    ]];
  });

  return [sendLabels containsObject:lower];
}

@interface MxFakeSendTarget : NSObject
+ (instancetype)shared;
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
@end

@implementation MxFakeSendTarget

+ (instancetype)shared {
  static MxFakeSendTarget *shared = nil;
  static dispatch_once_t token;
  dispatch_once(&token, ^{ shared = [MxFakeSendTarget new]; });
  return shared;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
  if (gesture.state != UIGestureRecognizerStateBegan) return;

  UIView *view = gesture.view;
  UIViewController *controller = mxEnclosingChatController(view);
  if (!controller) return;

  UITextView *composer = mxComposerTextView(controller);
  NSString *text = [composer.text
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  if (text.length == 0) {
    MxShowToast(MxFakeLoc(@"FAKE_MESSAGE_EMPTY_TOAST"));
    return;
  }

  long long peerId = mxPeerIdForChatController(controller);
  if (peerId == 0) {
    MxShowToast(MxFakeLoc(@"FAKE_MESSAGE_NO_PEER_TOAST"));
    return;
  }

  UIAlertController *sheet = [UIAlertController
      alertControllerWithTitle:nil
                       message:nil
                preferredStyle:UIAlertControllerStyleActionSheet];

  [sheet addAction:[UIAlertAction
                       actionWithTitle:MxFakeLoc(@"FAKE_MESSAGE_SEND_AS_PEER")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                 [MxFakeMessageStore addText:text forPeer:peerId];
                                 mxClearComposer(composer);
                                 mxRefreshOverlayForController(controller);
                               }]];

  [sheet addAction:[UIAlertAction actionWithTitle:MxFakeLoc(@"CANCEL")
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];

  // Required on iPad, where an unanchored action sheet throws.
  sheet.popoverPresentationController.sourceView = view;
  sheet.popoverPresentationController.sourceRect = view.bounds;

  UIViewController *presenter = controller;
  while (presenter.presentedViewController) {
    presenter = presenter.presentedViewController;
  }
  [presenter presentViewController:sheet animated:YES completion:nil];
}

@end

// ASDisplayNode is Telegram's private AsyncDisplayKit node class, and
// ChatControllerImpl is the concrete chat screen. Neither lives in a header we
// can import: UIHooks.xm declares them inline for its own use, and each .xm is
// a separate translation unit, so the declarations do not carry over. A
// category is not an option either, since a category requires the class to
// already have a visible @interface. Redeclaring here is safe because these are
// compile-time descriptions only; the real classes come from the host app at
// runtime and both files agree on the members they use.
@interface ASDisplayNode : NSObject
@property (atomic, assign, readonly) UIView *view;
@property (atomic, copy, readwrite) NSString *accessibilityLabel;
// Backed by %property below, so it must be visible for self.mxFakeSendGesture
// to type-check inside the hook.
@property (nonatomic, strong) UILongPressGestureRecognizer *mxFakeSendGesture;
@end

// Subclassing UIViewController is what gives us .view, .presentedViewController
// and friends on self inside the hook below.
@interface _TtC10TelegramUI18ChatControllerImpl : UIViewController
@end

%hook ASDisplayNode

%property(nonatomic, strong) UILongPressGestureRecognizer *mxFakeSendGesture;

- (void)setAccessibilityLabel:(NSString *)label {
  %orig;

  if (!mxLabelIsSendButton(label)) return;

  @try {
    UIView *view = self.view;
    if (!view) return;

    if (!self.mxFakeSendGesture) {
      UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
          initWithTarget:[MxFakeSendTarget shared]
                  action:@selector(handleLongPress:)];
      // A long press on the send button already means "schedule / send without
      // sound" in stock Telegram. Letting the touch through keeps that menu
      // working instead of replacing it.
      gesture.cancelsTouchesInView = NO;
      gesture.delaysTouchesBegan = NO;
      gesture.delaysTouchesEnded = NO;
      gesture.minimumPressDuration = 0.45;
      self.mxFakeSendGesture = gesture;
    }

    if (![view.gestureRecognizers containsObject:self.mxFakeSendGesture]) {
      [view addGestureRecognizer:self.mxFakeSendGesture];
    }
  } @catch (NSException *e) {}
}

%end

// Keeps the bubbles above the input panel as the keyboard opens and closes and
// as the panel grows with a multi-line draft.
%hook _TtC10TelegramUI18ChatControllerImpl

- (void)viewDidLayoutSubviews {
  %orig;
  @try {
    MxFakeMessageOverlay *overlay =
        (MxFakeMessageOverlay *)[self.view viewWithTag:kMxFakeOverlayTag];
    if (overlay && [overlay isKindOfClass:[MxFakeMessageOverlay class]]) {
      [self.view bringSubviewToFront:overlay];
      [overlay reload];
    }
  } @catch (NSException *e) {}
}

- (void)viewDidAppear:(BOOL)animated {
  %orig;
  @try {
    // Only builds an overlay when this chat actually has fakes stored, so every
    // other conversation is left untouched.
    long long peerId = mxPeerIdForChatController((UIViewController *)self);
    if (peerId == 0) return;
    if ([MxFakeMessageStore messagesForPeer:peerId].count == 0) return;
    mxRefreshOverlayForController((UIViewController *)self);
  } @catch (NSException *e) {}
}

%end

// ============================================================
// Entry points used by the Mx menu
// ============================================================

NSInteger MxFakeMessagesCount(void) {
  return [MxFakeMessageStore totalCount];
}

void MxFakeMessagesClearAll(void) {
  [MxFakeMessageStore removeAll];

  // Tear the bubbles down in whatever chat is on screen; the store being empty
  // is not enough on its own, because nothing re-lays out until the user moves.
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) return;

    NSMutableArray<UIView *> *queue = [NSMutableArray arrayWithObject:window];
    while (queue.count > 0) {
      UIView *view = queue.firstObject;
      [queue removeObjectAtIndex:0];
      if (view.tag == kMxFakeOverlayTag &&
          [view isKindOfClass:[MxFakeMessageOverlay class]]) {
        [view removeFromSuperview];
        continue;
      }
      [queue addObjectsFromArray:view.subviews];
    }
  });
}

%ctor {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    @try {
      Class asDisplayNode = objc_getClass("ASDisplayNode");
      Class chatController = objc_getClass("_TtC10TelegramUI18ChatControllerImpl")
                                 ?: objc_getClass("_TtC10TelegramUI14ChatController");
      if (asDisplayNode) {
        %init(ASDisplayNode = asDisplayNode,
              _TtC10TelegramUI18ChatControllerImpl = chatController);
      }
    } @catch (NSException *e) {
      NSLog(@"[Mx] fake message hooks init failed: %@", e);
    }
  });
}
