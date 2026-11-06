# Auditors can view the Key Vault's configuration but cannot read secrets.

resource "azuread_group" "auditors" {
  display_name     = "sg-${local.name_base}-auditors"
  description      = "View Key Vault settings for audits. No access to secret values."
  security_enabled = true
  owners           = local.group_owners
}

resource "azurerm_role_assignment" "auditors_kv_reader" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azuread_group.auditors.object_id
  principal_type       = "Group"
}