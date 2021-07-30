resource "azurerm_virtual_wan" "vwan" {
  name                              = "vwan-${var.env["name"]}"
  resource_group_name               = var.rgName
  location                          = var.env["region"]
  type                              = "standard"
  disable_vpn_encryption            = false
  allow_branch_to_branch_traffic    = true
  office365_local_breakout_category = "None"
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "vhub-${var.env["name"]}-${var.env["region"]}"
  resource_group_name = var.rgName
  location            = var.env["region"]
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.0.0.0/23"
}

output "vwan-id" {
    value = azurerm_virtual_wan.vwan.id
}

output "vhub-id" {
    value = azurerm_virtual_hub.vhub.id
}