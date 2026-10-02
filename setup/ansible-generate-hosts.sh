#!/usr/bin/env bash
set -euo pipefail
# The caller supplies registered infrastructure outputs; this script does not call Terraform.
python3 - <<'PYTHON'
import ipaddress, os, re
from pathlib import Path
values = {
    "mariadb_ip": "MARIADB_PUBLIC_IP", "emr_ip": "EMR_PUBLIC_IP",
    "db_host": "MARIADB_PRIVATE_IP", "emr_host": "EMR_PRIVATE_IP",
    "mariadb_ssh_user": "TF_VAR_mariadb_admin_username",
    "emr_ssh_user": "TF_VAR_emr_admin_username",
    "ssh_private_key": "ANSIBLE_ssh_private_key_path",
}
text = Path("ansible/inventory/hosts.ini.template").read_text()
for placeholder, setting in values.items():
    value = os.environ.get(setting, "")
    if not value or any(c.isspace() for c in value) or any(c in value for c in "'\";#"):
        raise SystemExit("Missing or invalid registered setting: " + setting)
    if placeholder in {"mariadb_ip", "emr_ip", "db_host", "emr_host"}:
        ipaddress.ip_address(value)
    if placeholder.endswith("ssh_user") and not re.fullmatch(r"[a-z_][a-z0-9_-]*", value):
        raise SystemExit("Invalid host account: " + setting)
    text = text.replace("{" + placeholder + "}", value)
path = Path("ansible/inventory/hosts.ini")
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd, "w") as output:
    output.write(text)
print("Host inventory created from registered infrastructure outputs.")
PYTHON
