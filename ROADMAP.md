# MikrOS Linux Roadmap

## M0 — Architecture and minimum-platform definition

- [x] Define project scope and design principles.
- [x] Establish initial architecture candidates: m68k, 32-bit ARM, 32-bit x86, 32-bit PowerPC, RISC-V 32-bit and RISC-V 64-bit.
- [ ] Determine the minimum maintainable Linux kernel baseline.
- [ ] Determine minimum CPU/MMU requirements for each target, explicitly supporting both Linux/MMU and Linux/no-MMU where practical.
- [ ] Define Linux/no-MMU (uClinux) as a first-class MikrOS Linux profile rather than a separate repository.
- [ ] Qualify ColdFire V2/no-MMU with an MCF5208-class reference target and reproducible serial boot evidence.
- [ ] Coordinate the MCF5208-class target with mVM ColdFire qualification and use QEMU as a differential/reference platform where applicable.
- [ ] Determine minimum practical RAM and storage targets.
- [ ] Select libc/userspace strategy.
- [ ] Select init and base command strategy.
- [ ] Establish cross-toolchain builds.
- [ ] Establish emulator reference machines.
- [ ] Define riscv32 and riscv64 Linux/MMU baselines, cross-toolchains and kernel configurations.
- [ ] Qualify QEMU as the initial riscv32/riscv64 reference and CI platform.
- [ ] Defer selection of physical RISC-V reference boards until the architecture-level minimum requirements and qualification contract are established.
- [ ] Define automated boot/qualification criteria.
- [ ] Produce the first reproducible minimal root filesystem.

### M0 exit criteria

M0 is complete when every Tier-1 architecture has a documented CPU/MMU or no-MMU baseline, toolchain, reference emulator, kernel configuration and reproducible boot path to a usable shell. For m68k this includes a documented ColdFire V2/no-MMU path and MCF5208-class reference target.

## M1 — First bootable distribution

Build reproducible kernel + root filesystem images for the Tier-1 reference targets and qualify basic console, filesystem, process and shutdown/reboot behaviour.

## M2 — Minimal networking

Introduce architecture-appropriate networking, DHCP/static configuration, DNS and a small remote-access/tooling profile.

## M3 — Package/build system

Introduce a deliberately small package recipe/build model. Do not inherit a heavyweight package manager merely for compatibility.


## M4 — Linux/no-MMU (uClinux) qualification

- Produce a reproducible MikrOS Linux/no-MMU root filesystem and kernel configuration.
- Boot the ColdFire V2/MCF5208-class reference target to a usable MikrOS shell.
- Qualify process, filesystem, console, networking and package/build behavior under no-MMU constraints.
- Document no-MMU-specific limitations without forking the MikrOS user experience unnecessarily.
- Reuse the shared MikrOS package/repository/build model wherever technically practical.
- Add mVM ColdFire as a qualification runtime when its MCF5208 profile is available.
- Cross-check the reference ColdFire image against QEMU where applicable.

### M4 exit criteria

M4 is complete when MikrOS Linux/no-MMU is a reproducible, useful distribution profile rather than merely a kernel boot demonstration, with ColdFire V2/MCF5208-class qualification evidence and shared MikrOS package/build semantics.


## M5 — RISC-V qualification

- Qualify both riscv32 and riscv64 as first-class MikrOS Linux architectures.
- Produce reproducible kernel and MikrOS root filesystem images for each architecture.
- Boot both profiles under QEMU to a usable MikrOS shell.
- Qualify console, storage, networking, process execution and MPK/package workflows.
- Add automated riscv32 and riscv64 boot tests to CI.
- Document minimum ISA/extensions, RAM and platform requirements separately for 32-bit and 64-bit targets.
- Select physical reference hardware only after the QEMU architecture contracts are stable.
- Where useful, use RISC-V as a comparison/reference architecture in EduCPU material without coupling MikrOS to EduCPU.

### M5 exit criteria

M5 is complete when riscv32 and riscv64 each have a documented architecture contract, reproducible QEMU boot image, usable MikrOS userspace and automated CI qualification. Physical-board qualification may follow without blocking architecture-level support.
