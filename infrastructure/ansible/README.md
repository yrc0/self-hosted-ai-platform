# Ansible

Hosts are grouped by workload. The current inference server is `ai-inf-01`;
future inference VMs can be added to the same `inference` group.

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
│   └── inference.yml
└── roles/
    ├── linux_baseline/
    ├── model_storage/
    └── ollama/
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

`ai-app-01` uses the bootstrap secret for its SSH and managed sudo user, so
no additional application-user secret is required.

## Run inference servers

From this directory:

```sh
python3.14 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml
ansible all -m ping
ansible-playbook playbooks/inference.yml
```

Use the project virtual environment for every Ansible command. It avoids the
Homebrew Python 3.15 runtime. The inventory helper reads the bootstrap
credentials from Vault with `hvac`; they are kept ephemeral and are not written
to inventory files.

The playbook connects with the Vault-provided `itadmin` bootstrap account and
uses three focused roles: `linux_baseline` creates the managed sudo user and
installs prerequisites, `model_storage` safely configures the model disk, and
`ollama` installs and verifies Ollama with `qwen3:8b`.

The model-disk tasks fail closed unless exactly one unmounted,
unpartitioned disk between 180 GB and 220 GB is found. Existing disks are
never automatically formatted.

## Adding another inference VM

Add the VM under the `inference` group in `inventory/hosts.yml`:

```yaml
all:
  children:
    inference:
      hosts:
        another-vm:
          ansible_host: 172.30.30.122
```

Add `inventory/group_vars/another_vm.yml` for VM-specific Vault paths and
storage settings. No new playbook is needed when the VM has the same inference
workload.

## Run application servers

Open WebUI uses the reusable Docker and Open WebUI roles:

```sh
ansible-playbook playbooks/application.yml
```

Before deployment, the application VM verifies access to Ollama at
`172.30.30.121:11434`. The inference role binds Ollama to the VM network and
allows port 11434 only from `172.30.30.122` through UFW.

## Run monitoring servers

`mon-zbx-01` (Zabbix 7.0 + PostgreSQL) and `mon-metrics-01` (Prometheus +
Grafana) run in Docker and use the bootstrap account only.

Grafana admin credentials are read from Vault (`username`, `password`; both
non-empty single-line strings):

```text
secret/infrastructure/vms/mon-metrics-01/grafana
```

The credentials are stored in a root-only file on the metrics VM. Grafana uses
them when its database is first initialized; changing them in Vault later does
not reset an existing Grafana password.

Every playbook also installs `node_exporter` (scraped by Prometheus from
`172.30.30.22`) and Zabbix agent 2 (reporting to `172.30.30.21`). Where ufw is
enabled, those ports are allowed only from the monitoring servers.

```sh
ansible-playbook playbooks/monitoring.yml
ansible-playbook playbooks/inference.yml
ansible-playbook playbooks/application.yml
```

- Zabbix: `http://172.30.30.21` (default login `Admin` / `zabbix`; change it).
- Prometheus: `http://172.30.30.22:9090`
- Grafana: `http://172.30.30.22:3000`

Agents send `HostMetadata=linux`. In Zabbix, create an autoregistration action
matching that metadata to add hosts with the `Linux by Zabbix agent` template.
