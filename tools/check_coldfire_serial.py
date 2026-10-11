#!/usr/bin/env python3
"""Check a captured MikrOS serial boot log. No external dependencies.

The guest-side smoke test must emit the exact markers below *after* checking
the shell, filesystem and process execution. Kernel banners are insufficient.
"""
import argparse
from pathlib import Path
import sys

REQUIRED = (
    "MIKROS_COLDFIRE_BOOT: userspace",
    "MIKROS_COLDFIRE_BOOT: shell-ok",
    "MIKROS_COLDFIRE_BOOT: filesystem-ok",
    "MIKROS_COLDFIRE_BOOT: process-ok",
    "MIKROS_COLDFIRE_BOOT: PASS",
)
FAILURES = (
    "Kernel panic",
    "MIKROS_COLDFIRE_BOOT: FAIL",
    "Attempted to kill init",
)

def validate(log: str) -> list[str]:
    errors = []
    for failure in FAILURES:
        if failure in log:
            errors.append(f"failure marker: {failure}")
    positions = [log.find(marker) for marker in REQUIRED]
    for marker, position in zip(REQUIRED, positions):
        if position < 0:
            errors.append(f"missing marker: {marker}")
    if all(position >= 0 for position in positions) and positions != sorted(positions):
        errors.append("boot markers are out of order")
    return errors

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", type=Path, help="Captured QEMU serial output")
    args = parser.parse_args()
    try:
        log = args.log.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"FAIL: cannot read serial log: {exc}", file=sys.stderr)
        return 1
    errors = validate(log)
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print("PASS: MikrOS ColdFire userspace smoke markers verified")
    return 0

if __name__ == "__main__":
    sys.exit(main())
