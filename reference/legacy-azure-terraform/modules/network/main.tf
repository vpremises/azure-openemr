# VNET and Subnets
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "emr" {
  name                 = "emr-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IPs
resource "azurerm_public_ip" "db_pip" {
  name                = "${var.mariadb_vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku = "Basic"
}

resource "azurerm_public_ip" "emr_pip" {
  name                = "${var.emr_vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku = "Basic"
}

# NSG (shared)
resource "azurerm_network_security_group" "shared_nsg" {
  name                = "shared-vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "deny_ssh_all" {
  count = length(var.allowed_ssh_ips) == 0 ? 1 : 0

  name                        = "Deny-SSH-All"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.shared_nsg.name
}

# SSHルール (priority: 1000〜順に自動)
resource "azurerm_network_security_rule" "ssh_rules" {
  for_each = zipmap(distinct(var.allowed_ssh_ips), range(length(distinct(var.allowed_ssh_ips))))

  name                        = "SSH-Allow-${replace(replace(each.key, "/", "-"), ".", "-")}"
  priority                    = 1000 + each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = each.key
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.shared_nsg.name
}

resource "azurerm_network_security_rule" "allow_http_emr" {
  name                        = "Allow-HTTP-EMR"
  priority                    = 2000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.shared_nsg.name
}

resource "azurerm_network_security_rule" "allow_https_emr" {
  name                        = "Allow-HTTPS-EMR"
  priority                    = 2001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.shared_nsg.name
}

resource "azurerm_network_security_rule" "allow_mysql_from_emr" {
  name                        = "Allow-MySQL-From-EMR"
  priority                    = 2002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = azurerm_subnet.emr.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.shared_nsg.name
}

# NICs
resource "azurerm_network_interface" "dbnic" {
  name                = "${var.mariadb_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.db_pip.id
  }
}

resource "azurerm_network_interface" "emrnic" {
  name                = "${var.emr_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.emr.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.emr_pip.id
  }
}

# NSGとNICの関連付け
resource "azurerm_network_interface_security_group_association" "db_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.dbnic.id
  network_security_group_id = azurerm_network_security_group.shared_nsg.id
}

resource "azurerm_network_interface_security_group_association" "erm_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.emrnic.id
  network_security_group_id = azurerm_network_security_group.shared_nsg.id
}
