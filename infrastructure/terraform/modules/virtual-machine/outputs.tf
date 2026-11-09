output "id" {
  description = "vSphere managed object ID."
  value       = vsphere_virtual_machine.this.id
}

output "name" {
  description = "VM name."
  value       = vsphere_virtual_machine.this.name
}

output "ip_address" {
  description = "Configured IPv4 address."
  value       = var.ipv4_address
}
