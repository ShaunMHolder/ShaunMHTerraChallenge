# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # skip_provider_registration = true
}

resource "azurerm_resource_group" "sholder-sandbox" {
  name     = "sholder-sandbox"
  location = "East US"
  tags = {
    environment = "dev"
    owner       = "sholder"
  }

}

resource "azurerm_virtual_network" "Shaun-VN" {
  name                = "Shaun-Network"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "Shaun-Subnet-Web" {
  name                 = "Shaun-Subnet-Web"
  resource_group_name  = azurerm_resource_group.sholder-sandbox.name
  virtual_network_name = azurerm_virtual_network.Shaun-VN.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_subnet" "Shaun-Subnet-Data" {
  name                 = "Shaun-Subnet-Data"
  resource_group_name  = azurerm_resource_group.sholder-sandbox.name
  virtual_network_name = azurerm_virtual_network.Shaun-VN.name
  address_prefixes     = ["10.123.2.0/24"]
}

resource "azurerm_subnet" "Shaun-Subnet-Jumpbox" {
  name                 = "Shaun-Subnet-Jumpbox"
  resource_group_name  = azurerm_resource_group.sholder-sandbox.name
  virtual_network_name = azurerm_virtual_network.Shaun-VN.name
  address_prefixes     = ["10.123.3.0/24"]
}

resource "azurerm_network_security_group" "Shaun-SG-Web" {
  name                = "Shaun-SG-Web"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location
}

resource "azurerm_network_security_rule" "Shaun-dev-webrule" {
  name                        = "Shaun-dev-webrule"
  priority                    = 100
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "73.144.237.73/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sholder-sandbox.name
  network_security_group_name = azurerm_network_security_group.Shaun-SG-Web.name
}

resource "azurerm_subnet_network_security_group_association" "Shaun-dev-WebSGA" {
  subnet_id                 = azurerm_subnet.Shaun-Subnet-Web.id
  network_security_group_id = azurerm_network_security_group.Shaun-SG-Web.id
}

resource "azurerm_public_ip" "Shaun-pip-web" {
  name                = "Shaun-pip-web"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "Shaun-LinuxWeb-Adapter" {
  name                = "Shaun-LinuxWeb-Adapter"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Shaun-Subnet-Web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Shaun-pip-web.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "Shaun-Windows1-Adapter" {
  name                = "Shaun-Windows1-Adapter"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Shaun-Subnet-Jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "Shaun-vm-linuxweb1" {
  name                = "Shaun-vm-linuxweb1"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location
  size                = "Standard_B1ms"
  admin_username      = "SholderAdmin"
  network_interface_ids = [
    azurerm_network_interface.Shaun-LinuxWeb-Adapter.id,
  ]

  admin_ssh_key {
    username   = "SholderAdmin"
    public_key = file("./.ssh/AzureLabKey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "Windows1" {
  name                = "Windows1"
  resource_group_name = azurerm_resource_group.sholder-sandbox.name
  location            = azurerm_resource_group.sholder-sandbox.location
  size                = "Standard_B1ms"
  admin_username      = "SholderAdmin"
  admin_password      = "D0n0t4g3tm3!"
  network_interface_ids = [
    azurerm_network_interface.Shaun-Windows1-Adapter.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}