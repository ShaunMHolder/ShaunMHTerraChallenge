#Define Sandbox Resource Group
resource "azurerm_resource_group" "sholder-sandbox" {
  name     = var.RGName
  location = var.RGLocation
  tags = {
    environment = local.dev
    owner       = "sholder"
  }

}

#Create Virtual Network for Lab
resource "azurerm_virtual_network" "Shaun-VN" {
  name                = "Shaun-Network"
  resource_group_name = var.RGName
  location            = var.RGLocation
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = local.dev
  }
}

#Create Web Subnet
resource "azurerm_subnet" "Shaun-Subnet-Web" {
  name                 = "Shaun-Subnet-Web"
  resource_group_name  = var.RGName
  virtual_network_name = var.VNName
  address_prefixes     = ["10.123.1.0/24"]
}

#Create Data Subnet
resource "azurerm_subnet" "Shaun-Subnet-Data" {
  name                 = "Shaun-Subnet-Data"
  resource_group_name  = var.RGName
  virtual_network_name = var.VNName
  address_prefixes     = ["10.123.2.0/24"]
}

#Create Jumpbox Subnet
resource "azurerm_subnet" "Shaun-Subnet-Jumpbox" {
  name                 = "Shaun-Subnet-Jumpbox"
  resource_group_name  = var.RGName
  virtual_network_name = var.VNName
  address_prefixes     = ["10.123.3.0/24"]
}

#Create Web Security Group
resource "azurerm_network_security_group" "Shaun-SG-Web" {
  name                = "Shaun-SG-Web"
  resource_group_name = var.RGName
  location            = var.RGLocation

  tags = {
    environment = local.dev
  }
}

#Create Security Rule
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
  resource_group_name         = var.RGName
  network_security_group_name = var.SGWeb
}

#Associate Security Rule to Web Subnet
resource "azurerm_subnet_network_security_group_association" "Shaun-dev-WebSGA" {
  subnet_id                 = local.SNWebID
  network_security_group_id = local.SGWebID
}

#Create a Public IP
resource "azurerm_public_ip" "Shaun-pip-web" {
  name                = "Shaun-pip-web"
  resource_group_name = var.RGName
  location            = var.RGLocation
  allocation_method   = "Dynamic"

  tags = {
    environment = local.dev
  }
}

#Create Azure Linux Network Adapter And Associate Private IP on Web Subnet
resource "azurerm_network_interface" "Shaun-LinuxWeb-Adapter" {
  name                = "Shaun-LinuxWeb-Adapter"
  resource_group_name = var.RGName
  location            = var.RGLocation

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.SNWebID
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.PIPWebID
  }

  tags = {
    environment = local.dev
  }
}

#Create Windows Network Adapter on Jumpbox Subnet
resource "azurerm_network_interface" "Shaun-Windows1-Adapter" {
  name                = "Shaun-Windows1-Adapter"
  resource_group_name = var.RGName
  location            = var.RGLocation

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.SNJumpboxID
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = local.dev
  }
}
