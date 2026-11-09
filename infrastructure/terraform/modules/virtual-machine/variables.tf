variable "name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "template" {
  description = "Name or path of the source VM template."
  type        = string
}

variable "folder" {
  description = "vSphere VM folder path."
  type        = string
  default     = null
  nullable    = true
}

variable "datacenter" {
  description = "vSphere datacenter name."
  type        = string
}

variable "cluster" {
  description = "vSphere compute cluster name."
  type        = string
}

variable "datastore" {
  description = "vSphere datastore name."
  type        = string
}

variable "network" {
  description = "vSphere network or port group name."
  type        = string
}

variable "cpus" {
  description = "Number of virtual CPUs."
  type        = number
}

variable "memory_mb" {
  description = "Memory in megabytes."
  type        = number
}

variable "disk_sizes_gb" {
  description = "Disk sizes in gigabytes, in attachment order."
  type        = list(number)

  validation {
    condition     = length(var.disk_sizes_gb) > 0 && alltrue([for size in var.disk_sizes_gb : size > 0])
    error_message = "disk_sizes_gb must contain at least one positive disk size."
  }
}

variable "guest_id" {
  description = "vSphere guest OS identifier."
  type        = string
}

variable "firmware" {
  description = "VM firmware type."
  type        = string
  default     = "efi"

  validation {
    condition     = contains(["bios", "efi"], var.firmware)
    error_message = "firmware must be bios or efi."
  }
}

variable "scsi_type" {
  description = "Virtual SCSI controller type."
  type        = string

  validation {
    condition     = contains(["pvscsi", "lsilogic", "lsilogic-sas", "vmware:paravirtual"], var.scsi_type)
    error_message = "scsi_type must be pvscsi, vmware:paravirtual, lsilogic, or lsilogic-sas."
  }
}

variable "ipv4_address" {
  description = "Static IPv4 address."
  type        = string
}

variable "ipv4_netmask" {
  description = "IPv4 prefix length."
  type        = number
}

variable "ipv4_gateway" {
  description = "IPv4 default gateway."
  type        = string
}

variable "dns_servers" {
  description = "DNS server addresses."
  type        = list(string)
}

variable "dns_domain" {
  description = "Guest DNS search domain."
  type        = string
}

variable "guest_username" {
  description = "Guest operating system username."
  type        = string
}

variable "guest_password" {
  description = "Guest operating system password."
  type        = string
  sensitive   = true
}

variable "ssh_authorized_keys" {
  description = "SSH public keys for the guest user."
  type        = list(string)
}
