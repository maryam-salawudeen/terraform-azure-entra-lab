# A storage account with secure defaults. The settings that matter are
# commented so a reviewer can see why each one is set.

resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Cheapest option: standard performance, locally redundant.
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Reject anything older than TLS 1.2, and reject plain HTTP.
  min_tls_version            = "TLS1_2"
  https_traffic_only_enabled = true

  # No container can ever be made publicly readable.
  allow_nested_items_to_be_public = false

  # Don't let this account replicate data to accounts in other tenants.
  cross_tenant_replication_enabled = false

  # The portal uses Entra ID instead of account keys by default.
  default_to_oauth_authentication = true
  shared_access_key_enabled       = var.shared_access_key_enabled

  # Encrypt twice at rest (service level and infrastructure level).
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }
  }

  tags = var.tags
}
