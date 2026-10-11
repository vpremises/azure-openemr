variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "allowed_ssh_ips" {
  description = "List of allowed SSH IPs"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.allowed_ssh_ips) > 0
    error_message = "警告: SSHを開くIPが指定されていません。SSHがすべてブロックされます。"
  }
}

variable "mariadb_vm_name" {
  type        = string
}

variable "emr_vm_name" {
  type        = string
}
