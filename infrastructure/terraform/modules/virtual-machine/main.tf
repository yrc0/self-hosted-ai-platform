data "vsphere_datacenter" "this" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "this" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_datastore" "this" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_network" "this" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.this.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_virtual_machine" "this" {
  name             = var.name
  resource_pool_id = data.vsphere_compute_cluster.this.resource_pool_id
  datastore_id     = data.vsphere_datastore.this.id
  folder           = var.folder

  num_cpus  = var.cpus
  memory    = var.memory_mb
  guest_id  = var.guest_id
  firmware  = var.firmware
  scsi_type = var.scsi_type == "vmware:paravirtual" ? "pvscsi" : var.scsi_type

  network_interface {
    network_id   = data.vsphere_network.this.id
    adapter_type = "vmxnet3"
  }

  dynamic "disk" {
    for_each = var.disk_sizes_gb

    content {
      label            = "${var.name}-disk${disk.key}"
      unit_number      = disk.key
      size             = disk.key == 0 ? max(disk.value, data.vsphere_virtual_machine.template.disks[0].size) : disk.value
      thin_provisioned = true
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.name
        domain    = var.dns_domain
      }

      network_interface {
        ipv4_address = var.ipv4_address
        ipv4_netmask = var.ipv4_netmask
      }

      ipv4_gateway    = var.ipv4_gateway
      dns_server_list = var.dns_servers
    }
  }

}