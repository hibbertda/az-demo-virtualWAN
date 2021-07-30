variable "env" {
    type = map
}

variable "rgvnet1" {
  type = string
}

variable "rgvnet2" {
  type = string
}

variable "vhub-id" {
  type = string
}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-${var.env["name"]}-01"
  location            = var.env["region"]
  resource_group_name = var.rgvnet1
  address_space       = ["10.1.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "AzureBastionSubnet"
    address_prefix = "10.1.100.0/27"
  }
}

# Output the VNET ID
output "vnet1-id" {
  value = azurerm_virtual_network.vnet1.id
}