# MikrOS Linux

**MikrOS Linux** is a minimal Linux distribution for the oldest and smallest machines that can still run a maintainable Linux system.

It takes inspiration from Alpine Linux's minimalism and simplicity, with Debian-style pragmatism toward portability and architecture support.

## Goals

- Support the lowest practical Linux platform baseline per architecture.
- Prefer small, understandable components and minimal dependencies.
- Keep the system useful, not merely bootable.
- Make cross-compilation and emulator-first qualification first-class workflows.
- Avoid unnecessary daemons and runtime complexity.
- Keep architecture-specific compromises explicit and documented.

## Initial architecture candidates

M0 investigates m68k, 32-bit ARM and 32-bit x86. No CPU generation is supported until it passes MikrOS qualification.

## Principles

Minimum practical platform, small by default, upstream first, emulator first, simple administration, and no artificial runtime compatibility requirement with MikrOS ELKS.

## M0

M0 determines the true minimum supported platform for each initial architecture. See `ROADMAP.md` and `docs/targets.md`.

## License

Software authored specifically for MikrOS is intended to use the MIT License unless an imported component requires its upstream license. Third-party components retain their respective licenses.
