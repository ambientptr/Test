#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
void customLog(NSString *format, ...);
void customLog2(NSString *format, ...);
#ifdef __cplusplus
}
#endif

// Diagnostic logging for on-device testing.
//
// Deliberately NSLog rather than customLog2: customLog2 only writes to a file
// inside the app sandbox, which is unreachable from `idevicesyslog` on a
// tethered Mac. Set MX_DIAG to 0 to compile these out for a release build.
// Set to 1 for on-device debugging. Keep TLParser.diagEnabled in step — that
// one gates the Swift half, which this macro cannot reach.
#define MX_DIAG 0

// os_log rather than NSLog, and the format is a C string rather than an
// NSString: strings logged without a {public} annotation reach the syslog as the
// literal text "<private>", and clang only accepts that annotation inside
// os_log(). Scalars are public by default, so only %@ and %s need marking.
//
//     mxDiag("thing cls=%{public}@ id=%lld", cls, peerId);
#import <os/log.h>

#if MX_DIAG
#define mxDiag(fmt, ...) os_log(OS_LOG_DEFAULT, "[MxDiag] " fmt, ##__VA_ARGS__)
#else
#define mxDiag(fmt, ...) do { } while (0)
#endif
