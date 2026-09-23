# MikrOS Linux Roadmap

## M0 — Architecture and minimum-platform definition

- [x] Define project scope and design principles.
- [x] Establish initial architecture candidates: m68k, 32-bit ARM and 32-bit x86.
- [ ] Determine the minimum maintainable Linux kernel baseline.
- [ ] Determine minimum CPU/MMU requirements for each target.
- [ ] Determine minimum practical RAM and storage targets.
- [ ] Select libc/userspace strategy.
- [ ] Select init and base command strategy.
- [ ] Establish cross-toolchain builds.
- [ ] Establish emulator reference machines.
- [ ] Define automated boot/qualification criteria.
- [ ] Produce the first reproducible minimal root filesystem.

### M0 exit criteria

M0 is complete when every Tier-1 architecture has a documented CPU/MMU baseline, toolchain, reference emulator, kernel configuration and reproducible boot path to a usable shell.

## M1 — First bootable distribution

Build reproducible kernel + root filesystem images for the Tier-1 reference targets and qualify basic console, filesystem, process and shutdown/reboot behaviour.

## M2 — Minimal networking

Introduce architecture-appropriate networking, DHCP/static configuration, DNS and a small remote-access/tooling profile.

## M3 — Package/build system

Introduce a deliberately small package recipe/build model. Do not inherit a heavyweight package manager merely for compatibility.
