#!/bin/bash
set -euo pipefail

setup_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# Configuration is local and reviewable; no downloaded shell code is sourced.
source "$setup_dir/infracost-release.conf"
[[ "$INFRACOST_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Invalid release version' >&2; exit 2; }
[[ "$INFRACOST_RELEASE_ROOT" == https://* ]] || { echo 'HTTPS release source required' >&2; exit 2; }
[[ $(uname -s) == Linux ]] || { echo 'This installer supports Linux only' >&2; exit 2; }
case $(uname -m) in
  x86_64) architecture=amd64; expected=$INFRACOST_SHA256_AMD64 ;;
  aarch64|arm64) architecture=arm64; expected=$INFRACOST_SHA256_ARM64 ;;
  *) echo 'Unsupported CPU architecture' >&2; exit 2 ;;
esac
[[ "$expected" =~ ^[a-f0-9]{64}$ ]] || { echo 'Invalid release checksum' >&2; exit 2; }
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
asset="infracost-linux-$architecture"
curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
  "$INFRACOST_RELEASE_ROOT/v$INFRACOST_VERSION/$asset.tar.gz" -o "$work_dir/asset.tar.gz"
printf '%s  %s\n' "$expected" "$work_dir/asset.tar.gz" | sha256sum --check --status
# Extract only the expected regular binary, never arbitrary archive paths.
[[ $(tar -tzf "$work_dir/asset.tar.gz") == "$asset" ]] || { echo 'Unexpected release archive members' >&2; exit 2; }
[[ $(tar -tvzf "$work_dir/asset.tar.gz") == -* ]] || { echo 'Release member must be a regular file' >&2; exit 2; }
tar -xzf "$work_dir/asset.tar.gz" -C "$work_dir" -- "$asset"
install -m 0755 -- "$work_dir/$asset" "${INFRACOST_INSTALL_DIR:-/usr/local/bin}/infracost"
