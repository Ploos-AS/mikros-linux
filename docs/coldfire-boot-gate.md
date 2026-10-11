# ColdFire V2 boot qualification (work in progress)

Reference: QEMU `mcf5208evb`, ColdFire V2/MCF5208, Linux/no-MMU.
This document specifies the serial evidence contract; **it does not claim a
successful boot**. The pinned kernel config, image format, exact QEMU command
and compatible rootfs still need to be established and tested.

## Guest-side marker contract

Emit these exact lines **in order**, from guest userspace, only after each
corresponding real check succeeds:

```text
MIKROS_COLDFIRE_BOOT: userspace
MIKROS_COLDFIRE_BOOT: shell-ok
MIKROS_COLDFIRE_BOOT: filesystem-ok
MIKROS_COLDFIRE_BOOT: process-ok
MIKROS_COLDFIRE_BOOT: PASS
```

The shell check must execute a real command; filesystem check must read and
write an appropriate writable location; process check must start and wait for
a child process. Never print PASS unconditionally from init.

Capture serial output to a log and run:

```sh
python3 tools/check_coldfire_serial.py path/to/serial.log
```

The checker rejects missing or out-of-order markers and kernel panic / explicit
FAIL markers. It is only **one** CI gate: the QEMU runner must separately enforce
a finite timeout, expected emulator exit semantics, and upload the full serial
log. An empty log or a kernel-only boot must fail.

## Work remaining

1. Pin and validate kernel source/config against the MCF5208 board support.
2. Produce a compatible no-MMU userspace/rootfs with the existing toolchain.
3. Determine the board's supported boot image format and working QEMU command.
4. Implement guest-side smoke checks and deterministic exit/termination.
5. Add CI build/boot gate with timeout, SHA256 evidence and serial artifact.
6. Verify CI run, preserve i586 and classic m68k green gates.

See issue #1. Do not mark ColdFire boot-qualified before observed serial
evidence from a real QEMU run.
