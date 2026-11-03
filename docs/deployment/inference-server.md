# Inference server deployment

## Verified environment

The inference workload runs on the manually created `ai-inf-01` Ubuntu Server VM in the VMware environment. The VM uses the `aiadmin` Linux user and has:

- 12 vCPU
- 48 GB RAM
- 50 GB operating-system disk
- 200 GB model disk

The model filesystem is mounted at `/srv/ai/models`.

## Inference software

Ollama is installed on the VM and runs as a systemd service. The Qwen3 8B model is installed and has been tested from the terminal on the VM.

The existing VM was created manually in vCenter. Terraform has not provisioned this VM, and no Terraform state or provider configuration is included in this repository.

## Validation performed

The recorded validation is local terminal use of the installed Qwen3 8B model through the running Ollama service. This guide does not claim externally reachable connectivity, firewall configuration, remote access, benchmark results, or deployment of any additional service.
