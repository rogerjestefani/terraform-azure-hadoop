data "azurerm_image" "hadoop" {
  name_regex          = "${lookup(var.image, "name")}"
  resource_group_name = "${lookup(var.image, "resource_group")}"
  sort_descending     = "1"
}
