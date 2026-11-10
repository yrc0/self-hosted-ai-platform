terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.0.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }
}