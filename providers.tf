# Both providers use your Azure CLI login (az login) by default.
# Nothing here holds a tenant ID, subscription ID or secret.

provider "azurerm" {
  # When null, the provider reads ARM_SUBSCRIPTION_ID from the environment.
  subscription_id = var.subscription_id

  features {
    key_vault {
      # Keep soft-deleted vaults recoverable instead of purging them on destroy.
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      # Refuse to delete a resource group that still has resources Terraform
      # does not know about.
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azuread" {}
