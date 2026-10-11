output "emr_id" {
  value = azurerm_linux_virtual_machine.main.id
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_linux_virtual_machine.main.public_ip_address}"
}
