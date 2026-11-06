# An Entra ID security group plus the Azure RBAC roles it holds.
#
# Access goes to the group, never straight to a user. Adding or removing
# someone is then a group membership change, which is easy to review and
# easy to cover in an access review.

resource "azuread_group" "this" {
  display_name     = var.display_name
  description      = var.description
  security_enabled = true
  mail_enabled     = false
  owners           = var.owners

  # Stops Terraform from creating a second group with the same name.
  prevent_duplicate_names = true
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_group.this.object_id
  principal_type       = "Group"
}
