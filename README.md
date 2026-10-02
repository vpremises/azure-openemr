# OpenEMR host deployment example

An independently maintained vPremises example for configuring OpenEMR, MariaDB, PHP and Nginx on registered hosts. Upstream application source is obtained from `openemr/openemr`. This example remains separate from the NERP application and from patient/service data.

## Responsibility boundary

Azure resource creation, identities, networks and provider authorization belong to Zixcel. This package accepts the resulting host addresses as registered inputs. The retained `terraform/` files are historical reference inputs; the Makefile's cloud targets stop before any resource operation. See [RESPONSIBILITY.md](RESPONSIBILITY.md). No cloud resource provider is implemented or activated by this migration.

## Operator setup

Install Ansible with `make install-deps` if needed. Create a trusted local `.env` using `make setup-env`, then register `MARIADB_PUBLIC_IP`, `MARIADB_PRIVATE_IP`, `EMR_PUBLIC_IP`, `EMR_PRIVATE_IP`, host-account names and the SSH key path. The environment and generated inventory are excluded from Git. `make show-env` shows setting names with values redacted.

Generate inventory with `make ansible-generate-hosts`. Review the registered hosts and the playbooks before explicitly running `make emr`, which installs and configures services. Existing inventory files are not overwritten. Optional certificate issuance requires operator-supplied domain and contact settings. A source checkout or CI check never provisions infrastructure or deploys the example.

## Validation

Migration verification checks source, licensing, shell syntax, inventory generation using synthetic documentation addresses, and cloud-target refusal. Live Azure provisioning, SSH connections, OpenEMR installation and certificate issuance are not part of that verification.

## License

GPL-3.0, preserving the existing repository license. OpenEMR and third-party components retain their respective license terms.
