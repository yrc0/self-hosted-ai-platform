output "virtual_machines" {
  description = "Created virtual machine details."
  value = {
    for name, vm in module.virtual_machine : name => {
      id         = vm.id
      name       = vm.name
      ip_address = vm.ip_address
    }
  }
}
