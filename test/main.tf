terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# create resource group in eastus
resource "azurerm_resource_group" "rg" {
  name     = "testfw"
  location = "eastus"
}

# Azure Firewall Policy - Applied to Secure Virtual Hub
resource "azurerm_firewall_policy" "fwHubPol" {
  name                = "fwHubPolasdihu"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_firewall" "azfw" {
  name                = "azfw-sdpjuni"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  firewall_policy_id  = azurerm_firewall_policy.fwHubPol.id



  # virtual_hub = {
  #   virtual_hub_id    = var.vhub-id
  #   public_ip_count   = 1
  # }  
}