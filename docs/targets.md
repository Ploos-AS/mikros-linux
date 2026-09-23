# Target qualification

MikrOS Linux does not declare support solely because an architecture exists in the Linux source tree.

## Initial target matrix

| Target | Status | M0 question |
| --- | --- | --- |
| m68k | Candidate | Oldest practical MMU-capable m68k baseline? |
| ARM 32-bit | Candidate | Oldest practical ARM architecture/platform? |
| x86 32-bit | Candidate | Minimum CPU generation? |

## Qualification requirements

A Tier-1 reference target must build reproducibly, boot under an automatable emulator, reach a working console and shell, mount its root filesystem, execute basic process/filesystem tests, record RAM/image size, and cleanly reboot or halt where supported.

Real vintage hardware is valuable for later validation but is not required for M0.
