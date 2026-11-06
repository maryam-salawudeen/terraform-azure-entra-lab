# A storage account with secure defaults. The settings that matter are
# commented so a reviewer can see why each one is set.

resource "azurerm_storage_account" "this" {
  # Lab trade-offs, accepted on purpose. Each one is explained in the README.
  #checkov:skip=CKV_AZURE_59:Public endpoint kept so the lab can be reached from a laptop
  #checkov:skip=CKV2_AZURE_33:Private endpoints need a VNet and cost money, out of scope for the lab
  #checkov:skip=CKV_AZURE_206:LRS keeps cost down; lab data is disposable
  #checkov:skip=CKV2_AZURE_1:Microsoft-managed keys are enough for a lab with no real data
  #checkov:skip=CKV_AZURE_33:No queues are used in this account
  #checkov:skip=CKV2_AZURE_40:Shared key access is controlled by a variable, see storage_shared_key_enabled
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

  # Any SAS token signed with an account key should expire within a day.
  sas_policy {
    expiration_period = "01.00:00:00"
    expiration_action = "Log"
  }

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
