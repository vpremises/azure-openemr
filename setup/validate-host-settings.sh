#!/usr/bin/env bash
set -euo pipefail
# Refuse a deployment with blank or historical example credentials. Values are never logged.
for setting in ANSIBLE_mariadb_root_password ANSIBLE_mariadb_openemr_password; do
    value=${!setting:-}
    if [[ ${#value} -lt 16 || "$value" == *CHANGEME* || "$value" == *Mariadb123* ]]; then
        printf 'Register a unique password of at least 16 characters for %s.\n' "$setting" >&2
        exit 2
    fi
done
