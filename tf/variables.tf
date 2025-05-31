variable "rg1name" {
  type        = string
  description = "Used for naming the resource group"
}

variable "rg1location" {
  type        = string
  description = "Used for selecting the location"
  default     = "West US"
}

variable "prefix" {
  type        = string
  description = "Used for creating the virtual network prefix"
}

variable "vnet_cidr_prefix" {
  type        = string
  description = "Defines the address space of the VNet"
}

variable "subnet1_cidr_prefix" {
  type        = string
  description = "Defines the address range of Subnet1"
}

variable "vm_map" {
  type = map(object({
    name           = string
    size           = string
    admin_password = string
  }))

  default = {
    "vm1" = {
      name           = "vm1"
      size           = "Standard_B2s"
      admin_password = "P@ssw0rd2025!"
    },
    "vm2" = {
      name           = "vm2"
      size           = "Standard_B1s"
      admin_password = "P@ssw0rd2025!"
    },
    "vm3" = {
      name           = "vm3"
      size           = "Standard_D2_v3"
      admin_password = "P@ssw0rd2025!"
    }
  }
}
