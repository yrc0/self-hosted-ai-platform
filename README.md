# Self-Hosted AI Platform

This project documents and develops a modular, self-hosted AI assistant platform running on VMware ESXi 8, vCenter, and vSAN. The current platform includes a manually deployed Ubuntu inference VM running Ollama with Qwen3 8B; chat applications, agent tools, memory, access controls, automation, monitoring, and infrastructure automation remain planned work.

## Current infrastructure

- VMware environment: 3 ESXi hosts with 128 GB RAM each and approximately 9 TB of vSAN capacity.
- Inference VM: `ai-inf-01`, running Ubuntu Server with the `aiadmin` Linux user.
- VM resources: 12 vCPU, 48 GB RAM, a 50 GB operating-system disk, and a 200 GB model disk.
- Model storage: dedicated filesystem mounted at `/srv/ai/models`.
- Inference: Ollama runs as a systemd service, and Qwen3 8B is installed and tested locally in the terminal.

Only the inference workload above is deployed. The user-facing chat application and the other platform components are planned; no external connectivity or firewall configuration is documented as complete.

## Architecture

The intended platform is organized around virtualization, local inference, user applications, agent and tool integrations, data and memory, access and security, and operations. Technologies for future components remain open until selected and validated.

## Directory map

- `docs/`: Architecture, infrastructure, deployment, networking, security, and operations documentation.
- `infrastructure/`: Planned infrastructure-as-code and configuration-management workspaces.
- `services/`: Inference, applications, agents, data, security, and monitoring service boundaries.
- `scripts/`: Future maintenance and platform scripts.
- `tests/`: Future validation checks.

## Next work

The next workload is a user-facing chat application connected to the local inference service. Future work will add platform capabilities incrementally after design, product, and security choices are validated.

## Status boundary

This repository is a living engineering project. Its complete directory layout describes intended ownership and does not imply that every component has been implemented or deployed.
