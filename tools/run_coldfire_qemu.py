#!/usr/bin/env python3
"""Run an explicitly supplied ColdFire QEMU command and validate serial output.

The kernel image and QEMU arguments must come from a separately validated
MCF5208 boot recipe. This runner does not guess image format or machine flags.
"""
import argparse
from pathlib import Path
import subprocess
import sys

from check_coldfire_serial import validate


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=90)
    parser.add_argument("--allow-timeout-after-pass", action="store_true",
                        help="Accept QEMU timeout only when serial smoke passed")
    parser.add_argument("command", nargs=argparse.REMAINDER,
                        help="QEMU command following --")
    args = parser.parse_args()
    command = args.command
    if command and command[0] == "--":
        command = command[1:]
    if not command or Path(command[0]).name != "qemu-system-m68k":
        parser.error("supply an explicit qemu-system-m68k command after --")
    if args.timeout < 1:
        parser.error("--timeout must be positive")

    args.log.parent.mkdir(parents=True, exist_ok=True)
    timed_out = False
    try:
        with args.log.open("wb") as output:
            try:
                result = subprocess.run(
                    command, stdout=output, stderr=subprocess.STDOUT,
                    timeout=args.timeout, check=False,
                )
                status = result.returncode
            except subprocess.TimeoutExpired:
                timed_out = True
                status = None
    except OSError as exc:
        print(f"FAIL: unable to run QEMU: {exc}", file=sys.stderr)
        return 1

    log = args.log.read_text(encoding="utf-8", errors="replace")
    errors = validate(log)
    if timed_out and not args.allow_timeout_after_pass:
        errors.append("QEMU timed out")
    if not timed_out and status != 0:
        errors.append(f"QEMU exited with status {status}")
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        print(f"serial log: {args.log}", file=sys.stderr)
        return 1
    print(f"PASS: ColdFire userspace smoke verified; serial log: {args.log}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
