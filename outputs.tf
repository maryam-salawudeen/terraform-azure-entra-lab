output "resource_group_name" {
  description = "Name of the lab resource group."
  value       = azurerm_resource_group.lab.name
}

output "storage_account_name" {
  description = "Name of the lab storage account."
  value       = module.storage.name
}

output "key_vault_uri" {
  description = "URI of the lab Key Vault."
  value       = azurerm_key_vault.lab.vault_uri
}

output "group_object_ids" {
  description = "Object IDs of the Entra ID security groups, by role."
  value = {
    readers           = module.group_readers.object_id
    storage_operators = module.group_storage_operators.object_id
    kv_secret_readers = module.group_kv_secret_readers.object_id
    ca_pilot          = try(module.group_ca_pilot[0].object_id, null)
  }
}

output "policy_assignment_ids" {
  description = "IDs of the Azure Policy assignments on the resource group."
  value = {
    allowed_locations = azurerm_resource_group_policy_assignment.allowed_locations.id
    require_tag       = azurerm_resource_group_policy_assignment.require_tag.id
  }
}

output "conditional_access_policy_id" {
  description = "ID of the report-only Conditional Access policy, or null when it is turned off."
  value       = try(azuread_conditional_access_policy.require_mfa_pilot[0].id, null)
}
