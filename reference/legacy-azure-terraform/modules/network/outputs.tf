output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "mariadb_nic_id" {
  value = azurerm_network_interface.dbnic.id
}

output "emr_nic_id" {
  value = azurerm_network_interface.emrnic.id
}


output "db_public_ip" {
  value = azurerm_public_ip.db_pip.ip_address
}

output "db_private_ip" {
  value = azurerm_network_interface.dbnic.private_ip_address
}

output "emr_public_ip" {
  value = azurerm_public_ip.emr_pip.ip_address
}

output "emr_private_ip" {
  value = azurerm_network_interface.emrnic.private_ip_address
}
