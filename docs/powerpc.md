# PowerPC minimum platform

## M0 direction

MikrOS Linux includes **32-bit PowerPC** as an initial architecture family.

The first goal is not PPC64. It is to determine the oldest practical, currently maintainable 32-bit PowerPC + MMU combination that can run a useful MikrOS system.

## Initial CPU/platform classes

### Classic Book3S 32-bit

Current upstream Linux still contains the 32-bit Book3S/603 MMU path. This makes 603-class and related classic PowerPC systems an important M0 research target.

Potential later machine profiles include suitably supported classic Power Macintosh and other PReP/CHRP-era systems, but machine support must be qualified separately from CPU support.

### Embedded PowerPC

Current upstream Linux also retains several embedded PowerPC families, including 8xx and 83xx-class platform code.

These are valuable MikrOS candidates because constrained embedded systems match the project's purpose especially well.

## M0 candidate split

| Class | Candidate | Role |
| --- | --- | --- |
| Classic PPC32 | 603-class / Book3S 32 | minimum research candidate |
| Embedded PPC32 | 8xx-class | minimum embedded research candidate |
| Embedded PPC32 | 83xx-class | compatibility/reference candidate |
| PPC64 / PPC64LE | later | compatibility, not minimum-platform focus |

## Qualification rules

CPU support alone does not establish a MikrOS target. Each target requires:

- a maintained kernel configuration;
- working compiler and libc/userspace;
- an automatable emulator or reference machine;
- documented boot/storage/console path;
- measured RAM and storage requirements;
- MikrOS smoke-test qualification.

## Open M0 questions

- exact lowest currently upstream-supported classic PPC32 CPU;
- exact usable MMU requirements;
- best QEMU/reference board for the minimum target;
- libc/toolchain baseline;
- minimum useful RAM;
- whether classic and embedded PowerPC should both become Tier 1.

PowerPC 601 is not assumed to be supported. The minimum will be established from the selected kernel and complete system qualification rather than historical Linux support.
