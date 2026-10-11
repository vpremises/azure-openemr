
module "core" {
  source              = "./modules/core"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = module.core.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  allowed_ssh_ips = var.allowed_ssh_ips
  emr_vm_name = var.emr_vm_name
  mariadb_vm_name = var.mariadb_vm_name
  depends_on = [ module.core ]
}


module "emr" {
  source              = "./modules/emr"
  resource_group_name = module.core.resource_group_name
  location            = var.location
  admin_username          = var.emr_admin_username
  admin_password      = var.emr_admin_password
  vm_name = var.emr_vm_name
  vm_size = var.emr_vm_size
  nic_id = module.network.emr_nic_id
  ssh_public_key_path = var.ssh_public_key_path
  depends_on = [ module.network ]
}

module "mariadb" {
  source              = "./modules/mariadb"
  resource_group_name = module.core.resource_group_name
  location            = var.location
  admin_username          = var.mariadb_admin_username
  admin_password      = var.mariadb_admin_password
  vm_name = var.mariadb_vm_name
  vm_size = var.mariadb_vm_size
  nic_id = module.network.mariadb_nic_id
  ssh_public_key_path = var.ssh_public_key_path
  depends_on = [ module.network ]
}
