locals {
  location          = "${lookup(var.resource_group, "location")}"
  resource_group    = "${lookup(var.resource_group, "name")}"
  name              = "${var.name}-worker"
  number_of_workers = "${var.number_of_workers}"
  vm_size           = "${var.vm_size}"

  subnet_id             = "${lookup(var.subnet, "id")}"
  subnet_address_prefix = "${lookup(var.subnet, "address_prefix")}"

  username       = "${var.username}"
  ssh_public_key = "${var.ssh_public_key}"
  image_id       = "${data.azurerm_image.hadoop.id}"
  data_disk      = "${var.data_disk}"
}

resource "azurerm_availability_set" "worker" {
  name                = "${local.name}-availset"
  location            = "${local.location}"
  resource_group_name = "${local.resource_group}"
}

resource "azurerm_network_interface" "worker" {
  count               = "${local.number_of_workers}"
  name                = "${format("%s-%03d-nic", local.name, count.index + 1)}"
  location            = "${local.location}"
  resource_group_name = "${local.resource_group}"

  internal_dns_name_label = "${format("%s-%03d", local.name, count.index+1)}"

  ip_configuration {
    name                          = "${format("%s-%03d-ipconfig", local.name, count.index + 1)}"
    subnet_id                     = "${local.subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${cidrhost(local.subnet_address_prefix, count.index + 31)}"
  }
}

resource "azurerm_managed_disk" "volume_01" {
  count         = "${local.number_of_workers}"
  name          = "${format("%s-%03d-datadisk-01", local.name, count.index + 1)}"
  location      = "${local.location}"
  create_option = "Empty"
  disk_size_gb  = "${lookup(local.data_disk[0], "disk_size_gb")}"

  resource_group_name  = "${local.resource_group}"
  storage_account_type = "${lookup(local.data_disk[0], "storage_account_type")}"
}

resource "azurerm_managed_disk" "volume_02" {
  count         = "${local.number_of_workers}"
  name          = "${format("%s-%03d-datadisk-02", local.name, count.index + 1)}"
  location      = "${local.location}"
  create_option = "Empty"
  disk_size_gb  = "${lookup(local.data_disk[1], "disk_size_gb")}"

  resource_group_name  = "${local.resource_group}"
  storage_account_type = "${lookup(local.data_disk[1], "storage_account_type")}"
}

resource "azurerm_virtual_machine" "worker" {
  count                 = "${local.number_of_workers}"
  name                  = "${format("%s-%03d-vm", local.name, count.index+1)}"
  location              = "${local.location}"
  resource_group_name   = "${local.resource_group}"
  network_interface_ids = ["${element(azurerm_network_interface.worker.*.id, count.index)}"]
  vm_size               = "${local.vm_size}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = false

  storage_image_reference {
    id = "${local.image_id}"
  }

  storage_os_disk {
    name              = "${format("%s-%03d-osdisk", local.name, count.index + 1)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name            = "${element(azurerm_managed_disk.volume_01.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.volume_01.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 0
    caching         = "ReadOnly"
    disk_size_gb    = "${element(azurerm_managed_disk.volume_01.*.disk_size_gb, count.index)}"
  }

  storage_data_disk {
    name            = "${element(azurerm_managed_disk.volume_02.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.volume_02.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 1
    caching         = "ReadOnly"
    disk_size_gb    = "${element(azurerm_managed_disk.volume_02.*.disk_size_gb, count.index)}"
  }

  os_profile {
    computer_name  = "${format("%s-%03d", local.name, count.index + 1)}"
    admin_username = "${local.username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "${format("/home/%s/.ssh/authorized_keys", local.username)}"
      key_data = "${file("${local.ssh_public_key}")}"
    }
  }

  tags {
    role = "worker"
  }
}
