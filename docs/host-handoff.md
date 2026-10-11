# Registered host handoff v1

The provider owner supplies a reviewed, non-secret record identified as `vpremises://openemr/host-registration/v1`. Required fields are registration ID, provider owner alias, target/resource ID, environment, public/private IP addresses, network boundary (ingress sources and host-facing ports), reviewed host identity fingerprint and reviewer/time. The host owner verifies the record against the existing provider registration before generating a private local inventory. Unknown or mismatching target/identity requires a new review. This document does not implement or authorize Azure resource creation.

Passwords, access tokens, private keys, Terraform state, cloud credentials and database content never belong in this source record. SSH account and private key paths remain in the trusted local `.env`/inventory rather than a published handoff. Non-secret aliases are not authority to access the account.

Before a host rollout, record the host owner and approval for:

- HTTPS certificate/domain identity, protected NGINX routes and the intended ingress boundary.
- An independent DB backup and restoration into an isolated environment, with schema compatibility and measured recovery time.
- Exact application/configuration revisions and health criteria, including DB health.
- A maintenance window, reboot impact, approver and expiry.
- The previous reviewed artifact/configuration and DB recovery plan; rollback and health acceptance after restoration.

Keep configured, attempted, deployed and health-verified receipts separate. Current source CI proves host configuration regressions and legacy cloud rejection; it does not establish a live deployment, restore acceptance or provider identity.
