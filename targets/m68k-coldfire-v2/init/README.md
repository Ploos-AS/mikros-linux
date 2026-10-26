# ColdFire V2 no-MMU userspace toolchain

The kernel is compiled using Ubuntu's `m68k-linux-gnu-gcc -mcpu=5208`.
That compiler produces a valid ColdFire relocatable object from
`targets/m68k-coldfire-v2/init/init.c`, **not** a qualified Linux/no-MMU
executable. The CI runner has no `m68k-linux-uclibc-gcc` or `elf2flt`.

## Required deliverable

A reproducible, pinned toolchain targeting Linux/m68k ColdFire V2
(MCF5208), with a no-MMU-capable C library and a binary format supported
by the kernel configuration (typically BFLT via elf2flt). Toolchain
triplet names alone are not proof of ABI compatibility.

## Acceptance gate

1. Build `init.c` into a real target executable; record the compiler,
   library, ELF/BFLT conversion, `file` output, and checksums.
2. Validate its CPU instructions and format against the kernel's no-MMU
   executable loader. Do not use an ordinary glibc-linked m68k ELF.
3. Embed the executable as `/init` in the built-in initramfs. Create
   `/dev/console` (character device 5:1) in the archive manifest.
4. Boot QEMU `-M mcf5208evb -nographic`. The kernel must run PID 1
   and the serial log must contain `MIKROS_COLDFIRE_INIT_OK`.
5. Mark userspace PASS only after observing the serial marker. A kernel
   log saying `Run /init as init process` alone is insufficient.

## Current evidence

- Linux 6.12.58 boots to kernel serial console.
- Built-in initramfs is found; the kernel attempts to execute `/init`.
- Current `/init` is a shell-script sentinel without an interpreter.
- The C PID 1 probe compiles to a ColdFire m68k relocatable object.
- No compatible executable has been built or booted yet.

The immediate implementation task is to establish and pin the no-MMU
userspace toolchain, then replace the shell sentinel with the compiled
PID 1 binary. Avoid adding further rootfs features before this gate.
