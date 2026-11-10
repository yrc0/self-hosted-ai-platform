#!/usr/bin/env python3
"""Provide ephemeral SSH variables from the local Vault AppRole."""

import json
from pathlib import Path
import sys

import hvac
import yaml
import urllib3


ROOT = Path(__file__).parent
ALL_VARS = ROOT / "group_vars" / "all"
VM_VARS = ROOT / "group_vars" / "ai_inf_01.yml"
LOCAL_VARS = ALL_VARS / "vault.local.yml"


def load_yaml(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def inventory() -> dict:
    shared = load_yaml(ALL_VARS / "main.yml")
    local = load_yaml(LOCAL_VARS)
    vm = load_yaml(VM_VARS)

    client = hvac.Client(
        url=shared["vault_addr"],
        verify=shared["vault_validate_certs"],
    )
    if not shared["vault_validate_certs"]:
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    client.auth.approle.login(
        role_id=local["vault_role_id"],
        secret_id=local["vault_secret_id"],
    )
    bootstrap_secret = client.secrets.kv.v2.read_secret_version(
        mount_point=shared["vault_engine_mount"],
        path=vm["vault_bootstrap_secret_path"],
        raise_on_deleted_version=True,
    )["data"]["data"]
    managed_secret = client.secrets.kv.v2.read_secret_version(
        mount_point=shared["vault_engine_mount"],
        path=vm["vault_secret_path"],
        raise_on_deleted_version=True,
    )["data"]["data"]

    return {
        "ai_inf_01": {"hosts": ["ai-inf-01"]},
        "_meta": {
            "hostvars": {
                "ai-inf-01": {
                    "ansible_user": bootstrap_secret["username"],
                    "ansible_password": bootstrap_secret["password"],
                    "ansible_become_password": bootstrap_secret["password"],
                    "managed_guest_username": managed_secret["username"],
                    "managed_guest_password": managed_secret["password"],
                }
            }
        }
    }


if __name__ == "__main__":
    if "--list" not in sys.argv and "--host" not in sys.argv:
        raise SystemExit("use --list or --host")
    print(json.dumps(inventory() if "--list" in sys.argv else {}))
