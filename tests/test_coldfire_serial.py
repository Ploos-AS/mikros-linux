#!/usr/bin/env python3
"""Unit tests for ColdFire serial evidence checking (no QEMU required)."""
import importlib.util
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "tools" / "check_coldfire_serial.py"
spec = importlib.util.spec_from_file_location("coldfire_gate", SCRIPT)
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)

GOOD = "\n".join(gate.REQUIRED) + "\n"

class SerialGateTests(unittest.TestCase):
    def test_complete_log(self):
        self.assertEqual(gate.validate(GOOD), [])

    def test_embedded_markers_do_not_pass(self):
        self.assertTrue(gate.validate("\n".join("echo " + m for m in gate.REQUIRED)))

    def test_marker_prefix_does_not_pass(self):
        self.assertTrue(gate.validate("\n".join(m + " (not executed)" for m in gate.REQUIRED)))

    def test_empty_log(self):
        self.assertTrue(gate.validate(""))

    def test_kernel_only(self):
        self.assertTrue(gate.validate("Linux version 6.x\nBooting Linux\n"))

    def test_missing_process_check(self):
        self.assertTrue(gate.validate(GOOD.replace("MIKROS_COLDFIRE_BOOT: process-ok\n", "")))

    def test_out_of_order(self):
        markers = list(gate.REQUIRED)
        markers[1], markers[2] = markers[2], markers[1]
        self.assertTrue(gate.validate("\n".join(markers)))

    def test_panic_even_after_pass(self):
        self.assertTrue(gate.validate(GOOD + "Kernel panic - not syncing\n"))

    def test_explicit_failure(self):
        self.assertTrue(gate.validate(GOOD + "MIKROS_COLDFIRE_BOOT: FAIL\n"))

if __name__ == "__main__":
    unittest.main()
