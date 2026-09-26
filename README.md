# MikrOS Linux

**MikrOS Linux** is the Linux kernel/backend target of MikrOS for the oldest and smallest machines that can still run a maintainable Linux system.

MikrOS is one operating-system/distribution architecture across supported kernels. Linux and ELKS are backend targets, not separate MikrOS products. The Linux target follows MikrOS' shared package, build, configuration and administration model while using Linux-native components where appropriate.

It takes inspiration from Alpine Linux's minimalism and simplicity, with Debian-style pragmatism toward portability and architecture support.

## Goals

- Support the lowest practical Linux platform baseline per architecture.
- Prefer small, understandable components and minimal dependencies.
- Keep the system useful, not merely bootable.
- Share MikrOS package metadata, repository concepts, build conventions, configuration model and administration UX with other MikrOS backends where practical.
- Make cross-compilation and emulator-first qualification first-class workflows.
- Avoid unnecessary daemons and runtime complexity.
- Keep architecture-specific compromises explicit and documented.

## Initial architecture candidates

M0 investigates **m68k, 32-bit ARM, 32-bit x86 and 32-bit PowerPC**. No CPU generation is supported until it passes MikrOS qualification.

## Relationship to MikrOS ELKS

MikrOS Linux and MikrOS ELKS are two kernel/backend targets of the same MikrOS architecture.

They should share, where practical:

- package recipe and repository concepts,
- package naming and metadata,
- host-side build tooling,
- system configuration conventions,
- service-management concepts,
- release/version policy,
- user-facing administration conventions.

They do **not** require identical binaries, libc, init implementations or command implementations. Backend-specific components are expected whenever they are needed for maintainability or platform constraints.

## Principles

Minimum practical platform, small by default, upstream first, emulator first, simple administration, and shared MikrOS semantics without forcing binary-level compatibility between backends.

## M0

M0 determines the true minimum supported platform for each initial architecture. See `ROADMAP.md` and `docs/targets.md`.

## License

Software authored specifically for MikrOS is intended to use the MIT License unless an imported component requires its upstream license. Third-party components retain their respective licenses.
