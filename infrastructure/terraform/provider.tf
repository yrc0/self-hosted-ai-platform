provider "vsphere" {
  vsphere_server = var.vcenter_server

  user     = ephemeral.vault_kv_secret_v2.vcenter.data["username"]
  password = ephemeral.vault_kv_secret_v2.vcenter.data["password"]

  allow_unverified_ssl = var.vcenter_allow_unverified_ssl
}

provider "vault" {
  address          = var.vault_address
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
}