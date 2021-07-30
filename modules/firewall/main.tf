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
}

# Deploy Azure Firewall
# -- Ran into issue with deploying the Firewall with Terraform using the 'AZFW_HUB' sku.
# -- Resulting in an API error from Azure. To get around this the Firewall is deployed with an ARM template. 
resource "azurerm_resource_group_template_deployment" "azfw_template_deployment" {
  name                      = "azFW-hub-deployment"
  resource_group_name       = var.rgName
  
  deployment_mode           = "Incremental"
  template_content          = file("./modules/firewall/arm/azfw-hub.azrm.json")
  
 # ARM Template parameters
  parameters_content = jsonencode({
    azFwName                = { value = "azfw-${var.env["name"]}" }
    vhubid                  = { value = var.vhub-id }
    fwPolicyID              = { value = azurerm_firewall_policy.fwHubPol.id }
  })
}

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
    next_hop          = jsondecode(azurerm_resource_group_template_deployment.azfw_template_deployment.output_content).azFwID.value
  }
  # Force traffic to 'destinations' CIDR throught Azure Firewall
   route {
    name              = "local_traffic"
    destinations_type = "CIDR"
    destinations      = ["10.1.2.0/16"] 
    next_hop_type     = "ResourceId"
    next_hop          = jsondecode(azurerm_resource_group_template_deployment.azfw_template_deployment.output_content).azFwID.value    
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





# module "fwRules" {
#     source = "./rules"
#     env = var.env
#     rgname = var.rgName 
#     azfwName =    
# }





# Output - Policy Group resource ID
output "default-policyGroup" {
    value = azurerm_firewall_policy_rule_collection_group.fwHubPol-defaultPolCol.id
}

