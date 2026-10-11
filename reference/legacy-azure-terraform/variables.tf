
# Shared Settings
variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}


variable "allowed_ssh_ips" {
  type        = list(string)
  default     = []
}

variable "ssh_public_key_path" {
  type        = string
}


# MariaDB
variable "mariadb_vm_name" {
  default = "mariadb-vm"
}

variable "mariadb_vm_size" {
  description = "MariaDB Azure VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "mariadb_admin_username" {
  default = "adminuser"
}

variable "mariadb_admin_password" {
  sensitive = true
}

# OpenEMR
variable "emr_vm_name" {
  default = "emr-vm"
}

variable "emr_vm_size" {
  description = "OpenEMR Azure VM size"
  type        = string
  default     = "Standard_B2ms"
}

variable "emr_admin_username" {
  default = "adminuser"
}

variable "emr_admin_password" {
  sensitive = true
}
