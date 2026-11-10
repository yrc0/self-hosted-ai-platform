# Ansible

Each VM has its own inventory group, group-vars file, and playbook. The
current VM is `ai-inf-01`; future VMs use the same standard structure.

```text
ansible/
├── ansible.cfg
├── requirements.yml
├── README.md
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       ├── all/
│       │   ├── main.yml
│       │   └── vault.local.yml       # ignored AppRole credentials
│       ├── ai_inf_01.yml
├── playbooks/
│   └── ai-inf-01.yml
└── roles/
    └── ai_inference/
```

## Vault

Create the ignored AppRole credentials file:

```sh
cp inventory/group_vars/all/vault.local.yml.example \
   inventory/group_vars/all/vault.local.yml
```

Set the values in `inventory/group_vars/all/vault.local.yml`:

```yaml
vault_role_id: "..."
vault_secret_id: "..."
```

The file is ignored by Git and loaded automatically as variables for all
inventory hosts.

The VM bootstrap credentials are read from:

```text
secret/infrastructure/vms/bootstrap_user
```

The target user's credentials are read from:

```text
secret/infrastructure/vms/ai-inf-01
```

Both secrets must contain `username` and `password`.

## Run ai-inf-01

From this directory:

```sh
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
ansible all -m ping
ansible-playbook playbooks/ai-inf-01.yml
```

Use the project virtual environment for every Ansible command. It avoids the
Homebrew Python 3.15 runtime. The inventory helper reads the bootstrap
credentials from Vault with `hvac`; they are kept ephemeral and are not written
to inventory files.

The playbook connects with the Vault-provided `itadmin` bootstrap account,
creates the Vault-provided application user, configures the model disk, and
installs and verifies Ollama with `qwen3:8b`.

The model-disk tasks fail closed unless exactly one unmounted,
unpartitioned disk between 180 GB and 220 GB is found. Existing disks are
never automatically formatted.

## Adding another VM

Add the VM to `inventory/hosts.yml` under its own group:

```yaml
all:
  children:
    another_vm:
      hosts:
        another-vm:
          ansible_host: 172.30.30.122
```

Add `inventory/group_vars/another_vm.yml` for that VM's configuration and
create `playbooks/another-vm.yml`. Keep that VM's address, Vault paths, and
workload-specific settings in its own group-vars file. Reuse a role only when
the VM has the same workload requirements as `ai-inf-01`.
