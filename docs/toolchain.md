# Toolchain and build policy

MikrOS Linux is cross-built from a modern Linux host. Old target machines are runtime and qualification systems, not required build hosts.

## Compiler family

The M0 reference toolchain is GNU GCC, GNU binutils, GNU make/kernel tooling, and the architecture-selected musl or uClibc-ng. LLVM/Clang may be qualified later.

## Initial targets

| Target | CPU baseline | libc direction | build prefix |
| --- | --- | --- | --- |
| x86-i586 | i586 | musl | i586-linux-musl- |
| armv4t | ARMv4T + MMU | musl if qualified, otherwise uClibc-ng | arm-linux-* |
| m68k | 68020+MMU; 68030 reference | uClibc-ng | m68k-linux-uclibc- |
| ppc32 | 32-bit PowerPC | musl | powerpc-linux-musl- |

The exact ARM tuple remains open until libc/ABI qualification. Build scripts must not infer CPU capabilities solely from the tuple.

## Build-host contract

A clean modern Linux host must be able to fetch/verify pinned sources, construct or use the pinned cross-toolchain, build libc/userspace and kernel, assemble a root filesystem, create bootable artifacts, emit checksums/metadata, and invoke emulator qualification without target hardware.

## Reproducibility

Every release records the MikrOS commit, target/profile, kernel revision, compiler/binutils/libc/userspace versions, configuration hashes, build epoch policy, SHA-256 and image/rootfs sizes. Host paths, usernames and uncontrolled timestamps should not leak into artifacts where avoidable. SOURCE_DATE_EPOCH is used where supported.

## Toolchain pinning

MikrOS does not blindly use the host distribution's newest compiler. Each target pins a known-good toolchain generation. A toolchain update requires rebuild and boot qualification. Prefer the newest practical compiler/binutils combination that still correctly supports the documented minimum CPU.

## Optimization

Release builds are size-oriented. Start with -Os; evaluate -Oz only where supported and measured. Target ISA flags must match the documented minimum CPU, with no accidental newer instructions. Whole-system size and runtime measurements decide.

## Native compilation

Native compilers are optional later dev-profile packages. A target does not need enough resources to compile MikrOS itself to be fully supported.

## Build interface

M0 should grow a simple scriptable interface such as:

    make target=x86-i586 profile=minimal
    make target=m68k profile=minimal
    make target=armv4t profile=minimal
    make target=ppc32 profile=minimal

Containerized builders may improve reproducibility but are host conveniences, never target requirements.

## CI

Tier 1 requires CI to create/restore a verified toolchain, build from pinned inputs, boot an emulator/reference machine, reach the qualification shell, run smoke tests, and publish measurements/logs.

## M0 exit criteria

Toolchain M0 is complete when all initial Tier-1 candidates have a documented pinned compiler/binutils/libc combination and at least one target builds end-to-end from a clean modern Linux host.
