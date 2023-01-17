variable "env" {
    type = map
}

variable "rgName" {
  type = string
}

variable "vhub-id" {
  type = string
}

variable "vnet1-id" {
  type = string
}

# Azure Firewall Policy - Applied to Secure Virtual Hub
resource "azurerm_firewall_policy" "fwHubPol" {
  name                = "fwpolicy-${var.env["name"]}"
  resource_group_name = var.rgName
  location            = var.env["region"]
}

# Default Azure Firewall Policy Rule Collection Group
## -- Additional rules can be loaded using add-on module
resource "azurerm_firewall_policy_rule_collection_group" "fwHubPol-defaultPolCol" {
  name               = "fwpolicy-rcg-${var.env["name"]}"
  firewall_policy_id = azurerm_firewall_policy.fwHubPol.id
  priority           = 500

  application_rule_collection {
    name  = "example-application-Rule"
    priority = 1000
    action = "Deny"
    rule {
      name  = "rule1"
      protocols {
        type = "Https"
        port  = 443
      }
      source_addresses = [ "10.1.0.0/16" ]
      destination_fqdns = [ "*.microsoft.com" ]
    }
  }

}

# Deploy Azure Firewall
resource "azurerm_firewall" "azfw" {
  name                = "azfw-${var.env["name"]}"
  location            = var.env["region"]
  resource_group_name = var.rgName

  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  firewall_policy_id  = azurerm_firewall_policy.fwHubPol.id

  virtual_hub {
    virtual_hub_id    = var.vhub-id
    public_ip_count   = 1
  }  
}



# data "azurerm_firewall" "azfw" {
#   # depends_on = [
#   #   azurerm_resource_group_tempate_deployment.azfw_template_deployment
#   # ]
#   name = "azfw-${var.env["name"]}"
#   resource_group_name = var.rgName
# }

# Virtual Hub Route Table
resource "azurerm_virtual_hub_route_table" "hbrtInternet" {
name                = "demoDefaultRT"
  virtual_hub_id    = var.vhub-id
  labels              = ["VNET"]
  
  # Force all INTERNET traffic through Azure Firewall
  route {
    name              = "internet_traffic"
    destinations_type = "CIDR"
    destinations      = ["0.0.0.0/0"] 
    next_hop_type     = "ResourceId"
    next_hop          = dazurerm_firewall.azfw.id
    # next_hop          = jsondecode(azurerm_resource_group_template_deployment.azfw_template_deployment.output_content).azFwID.value
  }
  # Force traffic to 'destinations' CIDR throught Azure Firewall
   route {
    name              = "local_traffic"
    destinations_type = "CIDR"
    destinations      = ["10.2.0.0/16"] 
    next_hop_type     = "ResourceId"
    next_hop          = data.azurerm_firewall.azfw.id
    # next_hop          = jsondecode(azurerm_resource_group_template_deployment.azfw_template_deployment.output_content).azFwID.value    
   }
}

# vHub Connection
# - Connect remote virtual network to virtual hub
# - include custom route configuration to force INTERNET traffic through the Azure Firewall
resource "azurerm_virtual_hub_connection" "vhub-vnet1" {
  name                      = "example-vhub"
  virtual_hub_id            = var.vhub-id
  remote_virtual_network_id = var.vnet1-id
  internet_security_enabled = false
  depends_on = [
    azurerm_virtual_hub_route_table.hbrtInternet
  ]

  routing {
    associated_route_table_id   = azurerm_virtual_hub_route_table.hbrtInternet.id
    propagated_route_table {
        route_table_ids = [
            azurerm_virtual_hub_route_table.hbrtInternet.id
        ]
        labels  = ["VNET"]
    }
  }

}

# Output - Policy Group resource ID
output "default-policyGroup" {
    value = azurerm_firewall_policy_rule_collection_group.fwHubPol-defaultPolCol.id
}

# Output - Azure Firewall ID
output "azfw-name" {
  value = "azfw-${var.env["name"]}"
}
