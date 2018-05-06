variable "resource_group" {
  description = "(Required) Hadoop resource group info"
  type        = "map"

  default = {
    /* expected keys:
    name     -> hadoop resource group name
    location -> hadoop resource group location */
  }
}

variable "subnet" {
  description = "(Required) Hadoop subnet info"
  type        = "map"

  default = {
    /* expected keys:
    id             -> hadoop subnet id
    address_prefix -> hadoop subnet address prefix */
  }
}

variable "image" {
  description = "(Required)"
  type        = "map"

  default = {
    /*
    name           -> hadoop image name
    resource_group -> image resource group name */
  }
}

variable "ssh_public_key" {
  description = "(Required) Path to ssh public key to be used as authorized key on vm"
}

variable "name" {
  description = "(Optional)"
  default     = "hadoop"
}

variable "number_of_workers" {
  description = "(Optional)"
  default     = "2"
}

variable "vm_size" {
  description = "(Optional) https://docs.microsoft.com/pt-br/azure/virtual-machines/linux/sizes"
  default     = "Standard_DS1_v2"
}

variable "username" {
  description = "(Optional) Linux user to be created on vm"
  default     = "flora"
}

variable "data_disk" {
  description = "(Optional)"
  type        = "list"
  default     = []
}
