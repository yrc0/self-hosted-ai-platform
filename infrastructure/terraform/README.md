# Terraform VMware platform

This Terraform root module manages VMware VMs in the existing vCenter
environment. vCenter credentials are read from HashiCorp Vault, while Ansible
owns guest-user creation and passwords. Each future VM is one entry in
`terraform.tfvars`; the reusable VM implementation stays in
`modules/virtual-machine`.

## Deploying a VM

1. Copy `terraform.tfvars.example` to the ignored `terraform.tfvars` file and
   replace the placeholders with your environment values.
2. Add one object under `vms` for each VM.
3. Make sure `VAULT_TOKEN` is set in the shell running Terraform.
4. Run:

   ```sh
   terraform init
   terraform fmt -recursive
   terraform validate
   terraform plan
   terraform apply
   ```

The current `vms` entry creates `ai-inf-01`. To add another VM, copy that
object, change its map key and values, and use a unique IP address. The
`folder` attribute is optional; omit it to let vSphere use its default
destination.

The local tfvars file contains environment configuration and is ignored by Git.
Do not store the Vault token in tfvars or Git. Use a protected remote backend
before using this configuration for shared or production workloads.

The Vault provider reads `secret/infrastructure/vcenter`, which must contain
`username` and `password` fields. Terraform reads the Vault token from
`VAULT_TOKEN`.

## Root Terraform files

- `version.tf` pins the Terraform and vSphere provider versions.
- `provider.tf` configures the vCenter and Vault providers.
- `data.tf` reads the vCenter credential secret from Vault.
- `variables.tf` defines the vCenter, Vault, and reusable VM settings.
- `main.tf` loops over `var.vms` and calls the VM module once per entry.
- `outputs.tf` reports the ID, name, and configured IP of each VM.
- `terraform.tfvars` is the local, ignored environment configuration.
- `terraform.tfvars.example` is the safe starting template for local
  configuration.
- `.terraform.lock.hcl` records the selected provider checksum and version.

## VM module files

`modules/virtual-machine` is the reusable implementation. It:

- Looks up the datacenter, cluster, datastore, network, and source template.
- Clones the selected template.
- Configures CPU, memory, disk, network, and static guest networking.
- Exposes the VM ID, name, and configured IP to the root module.

Terraform intentionally does not create guest users. Ansible should create and
manage users using credentials from Vault. Add or modify VM entries in the root
`terraform.tfvars` file instead.

`netbox-01` is intentionally not defined or managed here. It was removed from
Terraform state without deleting the existing VM.

## Template requirements

The source Ubuntu templates should have VMware Tools/open-vm-tools and
cloud-init installed and configured to read VMware guestinfo data. The guest
must also support the selected vSphere customization settings. Validate a new
template with a test VM before using it for multiple workloads.
