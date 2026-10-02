# Host configuration belongs to vPremises. Resource provisioning belongs to Zixcel.
ENV_FILE := .env
.PHONY: emr setup-env install-deps show-env azure remove terraform-init terraform-plan terraform-estimate terraform-apply terraform-destroy ansible-generate-hosts ansible-run-playbook-mariadb ansible-run-playbook-emr clean

emr: ansible-generate-hosts ansible-run-playbook-mariadb ansible-run-playbook-emr

install-deps:
	./setup/install-ansible.sh

setup-env:
	./setup/setup-envs.sh

show-env:
	@awk -F= '/^[A-Za-z_][A-Za-z0-9_]*=/{print $$1 "=<redacted>"}' $(ENV_FILE)

# The retained Terraform sources are reference inputs, not an active provisioning entry point.
azure remove terraform-init terraform-plan terraform-estimate terraform-apply terraform-destroy:
	@echo "Azure resource operations belong to Zixcel. Supply registered host addresses to vPremises."
	@exit 2

ansible-generate-hosts:
	@set -a; . ./$(ENV_FILE); set +a; ./setup/ansible-generate-hosts.sh

ansible-run-playbook-mariadb:
	@set -a; . ./$(ENV_FILE); set +a; ANSIBLE_ROLES_PATH=ansible/roles ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/mariadb.yml

ansible-run-playbook-emr:
	@set -a; . ./$(ENV_FILE); set +a; ANSIBLE_ROLES_PATH=ansible/roles ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/openemr.yml

clean:
	@rm -f -- $(ENV_FILE)
