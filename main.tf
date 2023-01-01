resource "azurerm_resource_group" "my-sg" {
  name     = "My-Sg"
  location = "South India"
}

resource "azurerm_virtual_network" "my-vnet" {
  name                = "My-Vn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my-sg.location
  resource_group_name = azurerm_resource_group.my-sg.name
}

resource "azurerm_subnet" "my-subnet" {
  name                 = "My-Sub"
  resource_group_name  = azurerm_resource_group.my-sg.name
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "my-interface" {
  count               = var.network_interface_count
  name                = "My-Ni${count.index}"
  location            = azurerm_resource_group.my-sg.location
  resource_group_name = azurerm_resource_group.my-sg.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.my-subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_managed_disk" "managed_disk" {
  count                = var.managed_disk_count
  name                 = "datadisk_New_${count.index}"
  location             = azurerm_resource_group.my-sg.location
  resource_group_name  = azurerm_resource_group.my-sg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_availability_set" "avset" {
  name                         = "My-AvSet"
  location                     = azurerm_resource_group.my-sg.location
  resource_group_name          = azurerm_resource_group.my-sg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "my-vm" {
  count                 = var.instances_count
  name                  = "My-Vm${count.index}"
  location              = azurerm_resource_group.my-sg.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.my-sg.name
  network_interface_ids = [element(azurerm_network_interface.my-interface.*.id, count.index)]
  vm_size               = "Standard_B1s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "18.04.202112020"
  }

  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.managed_disk.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.managed_disk.*.id, count.index)
    create_option   = "Attach"
    lun             = 1 # Specifies the logical unit number of the data disk. This needs to be unique
    disk_size_gb    = element(azurerm_managed_disk.managed_disk.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}
