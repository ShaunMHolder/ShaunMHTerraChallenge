#Create Linux VM, and Use Linux Network Adapter, Use Private SSH Key
resource "azurerm_linux_virtual_machine" "Shaun-vm-linuxweb1" {
  name                = "Shaun-vm-linuxweb1"
  resource_group_name = var.RGName
  location            = var.RGLocation
  size                = "Standard_B1ms"
  admin_username      = "SholderAdmin"
  network_interface_ids = [
    local.NICLinux1,
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
  tags = {
    environment = "dev"
  }
}

#Create Windows VM Using Windows Network Adapter
resource "azurerm_windows_virtual_machine" "Windows1" {
  name                = "Windows1"
  resource_group_name = var.RGName
  location            = var.RGLocation
  size                = "Standard_B1ms"
  admin_username      = "SholderAdmin"
  admin_password      = "D0n0t4g3tm3!"
  network_interface_ids = [
    local.NICWin1,
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
  tags = {
    environment = "dev"
  }
}

#Create a Recovery Services Vault
resource "azurerm_recovery_services_vault" "Shaun-Dev-RSV" {
  name                = var.RSV1
  location            = var.RGLocation
  resource_group_name = var.RGName
  sku                 = "Standard"

  soft_delete_enabled = false
}

#Create a Backup Policy
resource "azurerm_backup_policy_vm" "Shaun-RSV1-BKP1" {
  name                = var.RSV1BKP1
  resource_group_name = var.RGName
  recovery_vault_name = azurerm_recovery_services_vault.Shaun-Dev-RSV.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

#Data for Linux Virtual Machines
data "azurerm_virtual_machine" "Dev-Data-Web" {
  name                = "Shaun-vm-linuxweb1"
  resource_group_name = var.RGName
}

#Data for Windows Virtual Machines
data "azurerm_virtual_machine" "Dev-Data-Jump" {
  name                = "Windows1"
  resource_group_name = var.RGName
}

#Protect Linux VM1
resource "azurerm_backup_protected_vm" "Shaun-protect-linuxweb1" {
  resource_group_name = var.RGName
  recovery_vault_name = var.RSV1
  source_vm_id        = data.azurerm_virtual_machine.Dev-Data-Web.id
  backup_policy_id    = azurerm_backup_policy_vm.Shaun-RSV1-BKP1.id
}

#Protect Windows VM1
resource "azurerm_backup_protected_vm" "Shaun-protect-Windows1" {
  resource_group_name = var.RGName
  recovery_vault_name = var.RSV1
  source_vm_id        = data.azurerm_virtual_machine.Dev-Data-Jump.id
  backup_policy_id    = azurerm_backup_policy_vm.Shaun-RSV1-BKP1.id
}