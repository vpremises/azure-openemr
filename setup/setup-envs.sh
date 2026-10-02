#!/usr/bin/env bash
set -euo pipefail
# Prepare local registration data without calling cloud APIs, discovering public IPs, or generating keys.
python3 - <<'PYTHON'
import os
from pathlib import Path
fd = os.open(".env", os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, "w") as output:
    output.write(Path(".env.template").read_text())
print("Local registration template created. Set trusted host, credential and key-path values before use.")
PYTHON
