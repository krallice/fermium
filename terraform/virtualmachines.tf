# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscriptionid
}
resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.location
}
resource "azurerm_virtual_network" "rg" {
  name                = "${var.vmbasename}-vnet1"
  address_space       = ["10.80.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "rg" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rg.name
  address_prefixes     = ["10.80.0.0/24"]
}
resource "azurerm_public_ip" "publicip" {
  count               = var.vmcount
  name                = "${var.vmbasename}-${format("%02d", count.index)}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"
  allocation_method   = "Static"
}
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vmbasename}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "PORT_80"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "PORT_443"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "PORT_8080"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ICMP"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "rg" {
  count               = var.vmcount
  name                = "${var.vmbasename}-${format("%02d", count.index)}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    # name                          = "${var.vmbasename}-niccfg-${count.index}"
    name                          = "${var.vmbasename}-${format("%02d", count.index)}-niccfg"
    subnet_id                     = azurerm_subnet.rg.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.*.id[count.index]
  }
}
resource "azurerm_network_interface_security_group_association" "rg" {
  count                     = var.vmcount
  network_interface_id      = azurerm_network_interface.rg.*.id[count.index]
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_linux_virtual_machine" "rg" {
  count = var.vmcount
  # name                = "${var.vmbasename}-${count.index}"
  name                = "${var.vmbasename}-${format("%02d", count.index)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.rg.*.id[count.index],
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  disable_password_authentication = false
}
resource "azurerm_virtual_machine_extension" "rg" {
  count 		= var.vmcount
  name 			= "deploy-fermium"
  virtual_machine_id	= azurerm_linux_virtual_machine.rg.*.id[count.index]
  publisher             = "Microsoft.Azure.Extensions"
  type			= "CustomScript"
  type_handler_version  = "2.0"
  settings		= <<SETTINGS
	{
		"fileUris": ["https://raw.githubusercontent.com/krallice/fermium/master/app/deploy-fermium.sh"],
		"commandToExecute": "./deploy-fermium.sh"
	}
SETTINGS
}
