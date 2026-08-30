// roothide.h — minimal declarations for the roothide path-remapping API.
//
// The upstream header ships with the roothide toolchain, which is not part of a
// plain Theos install. Implementations live in Sources/tgapiC/roothide_stub.m as
// identity operations, so TrollStore / sideloaded builds need only the
// declarations to compile.
//
// Signatures mirror roothide_stub.m exactly: the C-string variants are plain
// declarations, the ObjC variants are `overloadable`. Clang permits at most one
// non-overloadable function per overload set, which is why the char* forms must
// stay un-attributed.

#ifndef ROOTHIDE_H
#define ROOTHIDE_H

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

// Caller-owned copies (free() when done). Every pointer carries an explicit
// nullability specifier: the _Nonnull annotations on the ObjC forms below turn
// on -Wnullability-completeness for this whole header, which Theos builds with
// -Werror.
const char *_Nullable rootfs_alloc(const char *_Nullable path);
const char *_Nullable jbroot_alloc(const char *_Nullable path);
const char *_Nullable jbrootat_alloc(int fd, const char *_Nullable path);

// Randomised jailbreak root suffix; 0 when there is no roothide root.
unsigned long long jbrand(void);

// Cached variants — the returned pointer is owned by the callee.
const char *_Nullable jbroot(const char *_Nullable path);
const char *_Nullable rootfs(const char *_Nullable path);

#ifdef __cplusplus
}
#endif

NSString *_Nonnull __attribute__((overloadable)) jbroot(NSString *_Nonnull path);
NSString *_Nonnull __attribute__((overloadable)) rootfs(NSString *_Nonnull path);

#endif // ROOTHIDE_H
