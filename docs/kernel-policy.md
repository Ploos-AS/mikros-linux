# Kernel policy

MikrOS Linux aims to support old hardware without turning the distribution into an unmaintainable collection of permanently frozen kernels.

## Kernel tracks

### current

The primary development and qualification track follows a current upstream Linux release.

Purpose:

- discover regressions early;
- keep toolchain and architecture support current;
- make upstream-friendly fixes possible.

### stable

Release images should normally use a suitable maintained upstream stable/LTS kernel when that kernel preserves the required MikrOS architecture baseline.

This is the preferred production track.

### legacy

A legacy kernel track may exist when upstream has removed support for hardware that is important to the MikrOS mission.

Legacy is explicitly separate from the main maintained baseline.

Examples may include historical 386/486 x86 research or machine platforms removed from current Linux.

Legacy kernels:

- must be pinned exactly;
- must have a documented reason for existing;
- must not silently become the default kernel;
- must carry an explicit maintenance/security status;
- should receive only realistic backports;
- may be emulator/research-only when safe maintenance is no longer practical.

## Selection rule

MikrOS does **not** choose one kernel version for every architecture merely for version uniformity.

For each architecture, choose the newest maintainable kernel that:

1. supports the target CPU/platform;
2. works with the selected toolchain/libc/userspace;
3. passes MikrOS qualification;
4. has a realistic maintenance path.

Architecture-specific kernel versions are acceptable.

## Upstream first

MikrOS prefers unmodified upstream kernels.

Patch order:

1. use upstream functionality/configuration;
2. carry a small temporary MikrOS patch if required;
3. submit generally useful fixes upstream where practical;
4. avoid large permanent private kernel forks.

Every carried patch must document its origin, purpose and upstream status.

## Configuration

Kernel configurations are target-specific and versioned.

A minimum profile should enable only what is needed for:

- the reference machine;
- console/boot;
- required storage/root filesystem;
- proc/sys/dev support;
- networking when the profile requires it;
- qualification/debug facilities that justify their footprint.

Features are not enabled merely because a modern generic distribution normally enables them.

## Modules

Built-in drivers are preferred for the smallest boot-critical configurations when modules would add unnecessary complexity.

Modules remain available for profiles where they reduce total footprint or improve machine flexibility.

## Compression

Kernel and initramfs compression are chosen per target based on total cost:

- image size;
- decompressor size;
- RAM requirement;
- boot time on slow CPUs.

The smallest compressed file is not automatically the best choice for an 8080s/1990s-class CPU.

## Security and maintenance metadata

Every released target records:

- kernel version and source commit/tag;
- upstream maintenance status;
- MikrOS patch set;
- toolchain version;
- known unsupported mitigations/features where relevant;
- qualification date.

MikrOS must not describe an obsolete legacy kernel as secure merely because it still boots.

## M0 decision

The exact kernel versions remain a qualification result rather than a branding requirement.

M0 will test the initial x86, m68k, ARM and PowerPC candidates against current upstream and appropriate maintained stable/LTS branches, then pin per-architecture release baselines.
