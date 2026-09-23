# Userspace and libc policy

MikrOS Linux optimizes for the oldest practical maintained Linux targets. A single libc is desirable, but not at the cost of dropping an otherwise viable architecture.

## Default strategy

### musl — preferred default

Use musl wherever the architecture is supported and the selected CPU baseline can be qualified.

Reasons:

- small and simple runtime;
- static linking is practical;
- strong fit with the Alpine-inspired MikrOS philosophy;
- actively maintained.

### uClibc-ng — compatibility libc

Use uClibc-ng where it materially extends support for constrained/legacy Linux architectures that cannot use the preferred musl profile.

This is a deliberate compatibility backend, not a second default.

### glibc — exception path

glibc may be used for a machine/profile that requires it, but is not the preferred MikrOS base because minimum footprint is a core project goal.

## Initial architecture matrix

| Architecture | Preferred | Compatibility/research | M0 note |
| --- | --- | --- | --- |
| x86 i586 | musl | uClibc-ng | qualify i586 compiler/runtime |
| ARMv4T + MMU | musl research | uClibc-ng | verify exact musl CPU/ABI floor before Tier 1 |
| m68k 020+MMU | uClibc-ng research | glibc where needed | musl does not provide an upstream m68k port |
| PowerPC 32 | musl | uClibc-ng | qualify classic and embedded baselines separately |
| NOMMU targets | uClibc-ng research | architecture-specific | separate profile; do not constrain normal MMU userspace |

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

## Policy

Architecture-specific libc choices are acceptable. MikrOS compatibility is defined by system behaviour and administration conventions, not by forcing every target to use the same C library.
