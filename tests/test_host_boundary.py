import subprocess
import unittest
from pathlib import Path

class HostBoundary(unittest.TestCase):
    def test_every_legacy_cloud_entrypoint_is_rejected(self):
        root = Path(__file__).resolve().parents[1]
        for target in ["azure", "remove", "terraform-init", "terraform-plan", "terraform-estimate", "terraform-apply", "terraform-destroy"]:
            result = subprocess.run(["make", target], cwd=root, text=True, capture_output=True)
            self.assertNotEqual(result.returncode, 0, target)
            self.assertIn("Supply registered host addresses", result.stdout)
        self.assertFalse((root / "terraform").exists())
        self.assertTrue((root / "reference/legacy-azure-terraform/main.tf").is_file())

if __name__ == "__main__": unittest.main()
