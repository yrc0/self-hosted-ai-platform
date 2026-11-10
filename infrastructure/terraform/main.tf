module "virtual_machine" {
  for_each = var.vms

  source = "./modules/virtual-machine"

  name          = each.key
  template      = each.value.template
  folder        = each.value.folder
  datacenter    = var.vcenter_datacenter
  cluster       = var.vcenter_cluster
  datastore     = var.vcenter_datastore
  network       = var.vcenter_network
  cpus          = each.value.cpus
  memory_mb     = each.value.memory_mb
  disk_sizes_gb = each.value.disk_sizes_gb
  guest_id      = each.value.guest_id
  firmware      = each.value.firmware
  scsi_type     = each.value.scsi_type
  ipv4_address  = each.value.ipv4_address
  ipv4_netmask  = each.value.ipv4_netmask
  ipv4_gateway  = each.value.ipv4_gateway
  dns_servers   = each.value.dns_servers
  dns_domain    = each.value.dns_domain
}