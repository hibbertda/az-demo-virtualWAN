terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.69.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resourceGroups" {
    source  = "./modules/resourceGroups"
    env     = var.env
}

module "virtualWan" {
    source  = "./modules/virtualWAN"
    env     = var.env
    rgName  = module.resourceGroups.vwan-rg
}

module "virtualNetwork" {
    source  = "./modules/virtualNetwork"
    env     = var.env
    rgvnet1 = module.resourceGroups.vnet1-rg
    rgvnet2 = module.resourceGroups.vnet2-rg
    vhub-id = module.virtualWan.vhub-id
}

# Azure Firewall / Secure Virtual Hub
# - Deploy Azure Firewall
# - Create Azure Firewall Policy and example Policy Rule Group (prg)
# - Create any Rules based on example module
module "firewall" {
    source    = "./modules/firewall"
    env       = var.env
    rgName    = module.resourceGroups.vwan-rg
    vhub-id   = module.virtualWan.vhub-id
    vnet1-id  = module.virtualNetwork.vnet1-id
}


# module "fwRules" {
#     source = "./modules/firewall_rules"
#     env = var.env
#     rgName = module.resourceGroups.vwan-rg
#     azfw-name = module.firewall.azfw-name
# }