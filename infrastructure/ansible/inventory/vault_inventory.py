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
LOCAL_VARS = ALL_VARS / "vault.local.yml"
HOSTS_FILE = ROOT / "hosts.yml"


def load_yaml(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def inventory() -> dict:
    shared = load_yaml(ALL_VARS / "main.yml")
    local = load_yaml(LOCAL_VARS)
    static_inventory = load_yaml(HOSTS_FILE)
    host_groups = {}

    def collect_groups(groups: dict, parent_groups: list[str] | None = None) -> None:
        for group_name, group_data in (groups or {}).items():
            group_data = group_data or {}
            group_vars = load_yaml(ROOT / "group_vars" / f"{group_name}.yml")
            for host_name in (group_data.get("hosts") or {}):
                host_groups.setdefault(host_name, []).append((group_name, group_vars))
            collect_groups(group_data.get("children"), (parent_groups or []) + [group_name])

    collect_groups(static_inventory.get("all", {}).get("children"))

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
    hostvars = {}
    for host_name, groups in host_groups.items():
        _group_name, vm = next(
            (name, variables)
            for name, variables in groups
            if variables.get("vault_bootstrap_secret_path")
        )
        bootstrap_secret = client.secrets.kv.v2.read_secret_version(
            mount_point=shared["vault_engine_mount"],
            path=vm["vault_bootstrap_secret_path"],
            raise_on_deleted_version=True,
        )["data"]["data"]
        managed_secret = bootstrap_secret
        if not vm.get("vault_use_bootstrap_user", False):
            managed_secret = client.secrets.kv.v2.read_secret_version(
                mount_point=shared["vault_engine_mount"],
                path=vm["vault_secret_path"],
                raise_on_deleted_version=True,
            )["data"]["data"]
        hostvars[host_name] = {
            "ansible_user": bootstrap_secret["username"],
            "ansible_password": bootstrap_secret["password"],
            "ansible_become_password": bootstrap_secret["password"],
            "managed_guest_username": managed_secret["username"],
            "managed_guest_password": managed_secret["password"],
        }

    groups = {}
    for host_name, memberships in host_groups.items():
        for group_name, _variables in memberships:
            groups.setdefault(group_name, {"hosts": []})["hosts"].append(host_name)

    return {
        **groups,
        "_meta": {
            "hostvars": hostvars,
        },
    }


if __name__ == "__main__":
    if "--list" not in sys.argv and "--host" not in sys.argv:
        raise SystemExit("use --list or --host")
    print(json.dumps(inventory() if "--list" in sys.argv else {}))
