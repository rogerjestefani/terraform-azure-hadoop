variable "vnet" {
  description = "(Required) Vnet information where connect hadoop subnet"
  type        = "map"

  default = {
    /* expected keys:
    resource_group -> Resource group name of virtual network where hadoop subnet will be created.
    name           -> Virtual network name where hadoop subnet will be created.
    gateway_addr   -> IP address packets should be forwarded to, usually bastion IP address. */
  }
}

variable "subnet_block_id" {
  description = "(Optional) Subnet id for hadoop subnet, if subnet id is 70, and vnet cidr is 10.70.0.0/16, hadoop subnet cidr will be 10.70.70.0/24"
  default     = "70"
}

variable "name" {
  description = "(Optionl) General name to be used azure components that will be created, ie: resource group, subnets, route table, etc"
  default     = "hadoop"
}
