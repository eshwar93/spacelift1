terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
  subscription_id   = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id         = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_secret     = "xxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id         = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

# Create a resource group
resource "azurerm_resource_group" "rg1" {
  name     = "${var.rg1name}"
  location = "${var.rg1location}"
}


resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.prefix}-10"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  location            = "${azurerm_resource_group.rg1.location}"
  address_space       = ["${var.vnet_cidr_prefix}"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = "${azurerm_virtual_network.vnet1.name}"
  resource_group_name  = "${azurerm_resource_group.rg1.name}"
  address_prefixes     = ["${var.subnet1_cidr_prefix}"]
}
resource "azurerm_network_interface" "vm_nic" {
  for_each = var.vm_map  
  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "myfirst"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vm_map  
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = each.value.size
  admin_username      = "adminuser"
  admin_password      = each.value.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id,
  ]

  
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
  custom_data = base64encode(<<EOF
              #!/bin/bash
              echo "Hello From ${each.value.name} !"
              EOF


  )
}
