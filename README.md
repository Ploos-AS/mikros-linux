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

## Linux execution profiles

MikrOS Linux supports both Linux execution models where upstream support and the target architecture make them practical:

- **Linux/MMU** — the normal full Linux profile for MMU-capable systems.
- **Linux/no-MMU (uClinux)** — the no-MMU Linux profile for smaller embedded-class systems. uClinux is treated as an execution/profile name, not as a separate MikrOS product or repository.

Both profiles use the same MikrOS Linux repository and should share package metadata, build conventions, filesystem policy, configuration and administration semantics wherever practical.

## Initial architecture candidates

M0 investigates **m68k, 32-bit ARM, 32-bit x86, 32-bit PowerPC, RISC-V 32-bit and RISC-V 64-bit**. No CPU generation is supported until it passes MikrOS qualification.

For m68k, M0 explicitly investigates both classic MMU-capable m68k and **ColdFire V2/no-MMU**, with an **MCF5208-class target** as the initial ColdFire/uClinux reference. Later MMU-capable ColdFire targets may be qualified as Linux/MMU targets.

For RISC-V, **riscv32** and **riscv64** are explicit Linux/MMU architecture targets. QEMU is the initial reference and CI platform so the architecture contract can be qualified independently of a particular development board. Physical RISC-V reference hardware will be selected later based on maintainability, upstream support and MikrOS' minimum-platform goals.

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
