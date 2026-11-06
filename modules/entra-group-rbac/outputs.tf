output "object_id" {
  description = "Object ID of the group."
  value       = azuread_group.this.object_id
}

output "display_name" {
  description = "Display name of the group."
  value       = azuread_group.this.display_name
}

output "role_assignment_ids" {
  description = "IDs of the role assignments, keyed by the labels passed in."
  value       = { for k, ra in azurerm_role_assignment.this : k => ra.id }
}
