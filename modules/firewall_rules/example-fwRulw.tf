variable "env" {
  type = map
}

variable "rgName" {
  type = string
}

variable "azfw-name" {
  type = string
}

resource "azurerm_firewall_network_rule_collection" "example-network-rule" {
  name                = "testcollection"
  azure_firewall_name = var.azfw-name
  resource_group_name = var.rgName
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "10.0.0.0/16",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "8.8.8.8",
      "8.8.4.4",
    ]

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}