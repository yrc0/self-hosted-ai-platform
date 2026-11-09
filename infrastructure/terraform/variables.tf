variable "vcenter_server" {
  description = "Hostname or IP address of the vCenter server."
  type        = string
}

variable "vcenter_datacenter" {
  description = "Name of the vCenter datacenter."
  type        = string
}

variable "vcenter_cluster" {
  description = "Name of the vCenter compute cluster."
  type        = string
}

variable "vcenter_datastore" {
  description = "Name of the vCenter datastore."
  type        = string
}

variable "vcenter_network" {
  description = "Name of the vCenter network or port group."
  type        = string
}

variable "vcenter_user" {
  description = "User used by Terraform to connect to vCenter."
  type        = string
}

variable "vcenter_password" {
  description = "Password used by Terraform to connect to vCenter."
  type        = string
  sensitive   = true
}

variable "vcenter_allow_unverified_ssl" {
  description = "Whether to skip vCenter TLS certificate verification."
  type        = bool
  default     = false
}

variable "vms" {
  description = "Virtual machines to create, keyed by their vSphere VM name."
  type = map(object({
    template            = string
    folder              = optional(string)
    cpus                = number
    memory_mb           = number
    disk_sizes_gb       = list(number)
    guest_id            = string
    firmware            = string
    scsi_type           = string
    ipv4_address        = string
    ipv4_netmask        = number
    ipv4_gateway        = string
    dns_servers         = list(string)
    dns_domain          = string
    guest_username      = string
    ssh_authorized_keys = list(string)
  }))
}

variable "vm_guest_passwords" {
  description = "Guest passwords keyed by VM name."
  type        = map(string)
  sensitive   = true
}
