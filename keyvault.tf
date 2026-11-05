# Key Vault using Azure RBAC for data-plane access instead of the older
# access policies. Who can read secrets is then managed the same way as
# every other Azure permission: role assignments, ideally to groups.

resource "azurerm_key_vault" "lab" {
  name                = "kv-${var.prefix}-${random_string.suffix.result}"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true

  # Deleted vaults can be recovered for 7 days (the minimum).
  soft_delete_retention_days = 7
  purge_protection_enabled   = var.key_vault_purge_protection

  # Public endpoint stays on so you can reach the vault from your laptop.
  # Trusted Azure services can get through; everything else is allowed for
  # now. A real deployment would set default_action = "Deny" and use a
  # private endpoint or an IP allow list.
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = local.tags
}
