data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {}

# Storage account and Key Vault names have to be unique across all of Azure,
# so a short random suffix is added. It stays the same between runs because
# it lives in state.
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  name_base = "${var.prefix}-${var.environment}"

  tags = merge(
    {
      Owner       = var.owner_tag
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "terraform-azure-entra-lab"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${local.name_base}"
  location = var.location
  tags     = local.tags

  lifecycle {
    precondition {
      condition     = contains(var.allowed_locations, var.location)
      error_message = "var.location must be in var.allowed_locations, or the allowed locations policy will block the lab's own resources."
    }
  }
}

module "storage" {
  source = "./modules/secure-storage"

  name                      = "st${var.prefix}${random_string.suffix.result}"
  resource_group_name       = azurerm_resource_group.lab.name
  location                  = azurerm_resource_group.lab.location
  shared_access_key_enabled = var.storage_shared_key_enabled
  tags                      = local.tags
}
