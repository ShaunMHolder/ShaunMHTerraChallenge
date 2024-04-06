variable "RGName" {
  type    = string
  default = "sholder-sandbox"
}

variable "RGLocation" {
  type    = string
  default = "EastUS"
}

variable "VNName" {
  type    = string
  default = "Shaun-Network"
}

variable "SGWeb" {
  type    = string
  default = "Shaun-SG-Web"
}

variable "RSV1" {
  type    = string
  default = "Shaun-Dev-RSV"
}

variable "RSV1BKP1" {
  type    = string
  default = "Shaun-RSV1-BKP1"
}

variable "LinuxVM1" {
  type    = string
  default = "Shaun-vm-linuxweb1"
}



locals {
  SNWebID     = azurerm_subnet.Shaun-Subnet-Web.id
  SNJumpboxID = azurerm_subnet.Shaun-Subnet-Jumpbox.id
  SGWebID     = azurerm_network_security_group.Shaun-SG-Web.id
  PIPWebID    = azurerm_public_ip.Shaun-pip-web.id
  NICLinux1   = azurerm_network_interface.Shaun-LinuxWeb-Adapter.id
  NICWin1     = azurerm_network_interface.Shaun-Windows1-Adapter.id
  #BackupID    = azurerm_backup_policy_vm.Shaun-RSV1-BKP1.id
  dev         = "dev"
}