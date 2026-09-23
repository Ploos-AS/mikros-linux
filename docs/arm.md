# ARM minimum platform

## M0 direction

Current upstream Linux still contains ARMv4/ARMv4T support, including both MMU and no-MMU CPU classes.

MikrOS Linux therefore does not set ARMv5, ARMv6 or ARMv7 as an arbitrary minimum.

## Initial split

### Main MMU Linux profile

**ARMv4T + MMU** is the architectural minimum candidate.

The initial reference CPU candidate is **ARM720T**, which is an ARM7TDMI-derived ARMv4T processor with cache, write buffer and an MMU.

ARM920T/922T and later ARM9-class MMU systems are compatibility targets and may become more practical hardware reference platforms.

### no-MMU research profile

Current upstream also contains no-MMU support for processors such as:

- ARM7TDMI
- ARM740T
- ARM9TDMI
- ARM940T

This is deliberately separate from the main MikrOS Linux ARM profile. It may become a later MikrOS Linux NOMMU profile if a useful and maintainable userspace can be qualified.

## Why separate MMU and NOMMU

A CPU being supported by the kernel does not mean it can run the same userspace assumptions as normal MMU Linux. MikrOS must measure usefulness, maintainability, RAM/storage cost and toolchain support rather than advertising the oldest Kconfig symbol.

## M0 ARM targets

| Class | Candidate | Role |
| --- | --- | --- |
| MMU | ARM720T / ARMv4T | minimum architectural reference |
| MMU | ARM920T-class | practical early compatibility target |
| NOMMU | ARM7TDMI | research only |
| NOMMU | ARM9TDMI | research only |
| newer | ARMv5/v6/v7 | compatibility targets |

## Qualification still required

- select a current/LTS kernel policy;
- select a machine/platform that exposes the minimum CPU in an automatable emulator;
- qualify compiler and libc/userspace at ARMv4T;
- measure minimum useful RAM and storage;
- define ABI and floating-point policy;
- determine whether NOMMU deserves supported status.

No ARM target becomes Tier 1 until the complete machine, kernel and userspace combination boots and passes MikrOS smoke tests.
