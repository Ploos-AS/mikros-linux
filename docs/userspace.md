# Userspace and libc policy

MikrOS Linux optimizes for the oldest practical maintained Linux targets.

## Mandatory libc policy

> **Use musl where the target is supported. Use uClibc-ng where necessary to preserve an older or more constrained target.**

Hardware support takes priority over libc uniformity. MikrOS must not raise a CPU/platform minimum merely to force musl onto every architecture.

### musl — default

musl is the standard MikrOS Linux libc wherever the architecture and selected minimum CPU/ABI can be qualified.

### uClibc-ng — legacy/constrained backend

uClibc-ng is the standard fallback when musl does not support the architecture or when musl would force MikrOS to abandon an otherwise maintainable minimum platform.

This is intentional architecture support, not a lower-quality edition of MikrOS.

### glibc

glibc is not a standard MikrOS base libc. It may be used only for exceptional compatibility/research profiles that cannot reasonably use musl or uClibc-ng.

## Initial architecture matrix

| Architecture | MikrOS libc direction | M0 note |
| --- | --- | --- |
| x86 i586 | musl | qualify i586 compiler/runtime |
| ARMv4T + MMU | musl if minimum survives; otherwise uClibc-ng | hardware floor wins |
| m68k 020+MMU | uClibc-ng | upstream musl has no m68k port |
| PowerPC 32 | musl | qualify classic and embedded baselines separately |
| NOMMU targets | uClibc-ng where required | separate constrained profile |

## Base command environment

BusyBox is the preferred first base-userspace candidate where its architecture/toolchain combination qualifies.

MikrOS should not blindly enable every BusyBox applet. The base configuration is measured and deliberately selected.

Candidate base components:

- BusyBox init and shell
- core filesystem/process utilities
- mount/umount
- networking basics where applicable
- simple text configuration
- no background service unless the selected profile requires it

## Dynamic vs static

M0 should build and measure both where practical:

- a static rescue/minimal profile;
- a dynamically linked normal base profile.

The smaller *whole-system* result wins; individual executable size alone is not the metric.

## Compatibility principle

MikrOS compatibility is defined by system behaviour, filesystem conventions and administration interfaces. It is not defined by every architecture using the same C library.
