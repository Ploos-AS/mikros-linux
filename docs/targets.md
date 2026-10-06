# Target qualification

MikrOS Linux does not declare support solely because an architecture exists in the Linux source tree.

## M0 Tier-1 contract

Tier 1 is the architecture qualification set that blocks M0 completion.

| Target | Execution model | Minimum baseline | Initial reference | Status |
| --- | --- | --- | --- | --- |
| x86 32-bit | Linux/MMU | i586 | QEMU `pc` + Pentium | Qualified |
| m68k classic | Linux/MMU | 68020 + supported MMU | 68030-class reference | Toolchain qualified; boot qualification next |
| m68k ColdFire | Linux/no-MMU | ColdFire V2 | MCF5208-class reference | Required in M0 |
| ARM 32-bit | Linux/MMU | ARMv6 | QEMU/reference machine TBD | Contract |
| PowerPC 32-bit | Linux/MMU | PPC32 + MMU; exact CPU floor to be qualified | QEMU/reference machine TBD | Contract |

RISC-V 32-bit and 64-bit remain explicit MikrOS Linux architecture targets, but are qualified in the dedicated RISC-V milestone after the minimum legacy/embedded Tier-1 contract is established.

## Qualification requirements

A Tier-1 reference target must:

1. build reproducibly with a pinned toolchain and kernel source;
2. boot under an automatable reference emulator;
3. reach MikrOS userspace and a working console/shell;
4. mount or unpack its root filesystem successfully;
5. execute basic process and filesystem smoke tests;
6. record minimum/reference RAM and image size;
7. have a documented CPU, MMU/no-MMU, ABI, libc and boot contract;
8. cleanly reboot or halt where the reference platform supports it;
9. run as a required CI qualification gate.

Real vintage hardware is valuable for later validation but is not required for M0.

## x86-i586 evidence

The x86-i586 reference is qualified with both BIOS/GRUB boot and QEMU direct-kernel boot. Both paths must reach the MikrOS userspace banner and are required CI gates.

## Qualification order

After x86-i586, qualification proceeds:

1. classic m68k Linux/MMU;
2. ColdFire V2 Linux/no-MMU;
3. ARMv6 Linux/MMU;
4. PowerPC 32-bit Linux/MMU.

This order does not imply that later compatibility profiles are less important. It keeps M0 focused on proving the minimum-platform contract before expanding each architecture family.


## m68k classic evidence

The m68k cross-toolchain is CI-qualified for the M0 68020 ISA floor. The required CI job builds the pinned Buildroot/uClibc-ng toolchain and compiles and links a probe with `-m68020`.

This is toolchain qualification only. Full Tier-1 qualification still requires the minimal MikrOS userspace/root filesystem, Linux kernel configuration and reproducible reference-emulator boot to a usable console/shell.
