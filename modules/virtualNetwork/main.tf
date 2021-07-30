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

# resource "azurerm_virtual_hub_connection" "vhub-vnet1" {
#   name                      = "example-vhub"
#   virtual_hub_id            = var.vhub-id
#   remote_virtual_network_id = azurerm_virtual_network.vnet1.id
# }

# Output the VNET ID
output "vnet1-id" {
  value = azurerm_virtual_network.vnet1.id
}