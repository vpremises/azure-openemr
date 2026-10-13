# azure-openemr

Review an OpenEMR host deployment example and its separation from Azure resource provisioning.

## What you can do

- Configure the host-local deployment inputs.
- Understand which Azure provisioning work must be delegated to the configured integration.

## Current scope

The example does not create Azure resources as part of local setup. Registered secrets, deployment validation and operational access are required before use.

Package distribution is not activated by this documentation. Use the checked-in source and the declared dependency versions; published availability must be verified separately.

## Getting started

Start with the implementation and examples linked below. Review registered configuration and prerequisites before running a command that writes state or contacts a service.

## Documentation and source

[Interface reference](docs/interface-reference.md)

[Usage guide](docs/getting-started.md)

[Contributing](CONTRIBUTING.md) · [Security reporting](SECURITY.md) · [License](LICENSE) · [Attribution notices](NOTICE)

## Protected-directory regression checks

`python3 tests/test_nginx_protected_paths.py` renders the production NGINX
template and tests existing files under `sites/default/documents`, `edi`, and
`era` over HTTP and HTTPS in disposable Docker containers. Static and PHP
extensions must return 403 while a public JS file remains available; the
configured-domain HTTP entry redirects to HTTPS. Requires Jinja2, Docker,
OpenSSL, curl, and an already available NGINX image. Set `NGINX_TEST_IMAGE`
to an exact image digest for reproducible runs. Containers expose only ephemeral
loopback ports and are removed after the checks.

[OSS responsibility and source completion](docs/oss-source-contract.md) defines the supported package boundary and required acceptance. It does not declare unexecuted source, distribution or production checks complete.
