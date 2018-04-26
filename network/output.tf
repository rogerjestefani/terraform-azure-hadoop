output "resource_group" {
  description = "Hadoop created resource group info"
  depends_on  = ["azurerm_resource_group.hadoop"]

  value = {
    name     = "${azurerm_resource_group.hadoop.name}"
    location = "${azurerm_resource_group.hadoop.location}"
    tags     = "${azurerm_resource_group.hadoop.tags}"
  }
}

output "subnet" {
  description = "Hadoop created subnet info"
  depends_on  = ["azurerm_subnet.hadoop"]

  value = {
    id             = "${azurerm_subnet.hadoop.id}"
    address_prefix = "${azurerm_subnet.hadoop.address_prefix}"
  }
}
