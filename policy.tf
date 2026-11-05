# Policy as code: two built-in Azure Policy definitions assigned to the lab
# resource group. The definition IDs are Microsoft's fixed IDs for the
# built-ins, so no lookup is needed.

locals {
  policy_allowed_locations = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  policy_require_tag       = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
}

# Resources in this resource group can only be created in approved regions.
resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations (${local.name_base})"
  resource_group_id    = azurerm_resource_group.lab.id
  policy_definition_id = local.policy_allowed_locations
  enforce              = var.policy_enforcement

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })

  non_compliance_message {
    content = "Resources in this lab must be deployed to: ${join(", ", var.allowed_locations)}."
  }
}

# Every taggable resource in this resource group must carry the required tag.
resource "azurerm_resource_group_policy_assignment" "require_tag" {
  name                 = "require-${lower(var.required_tag_name)}-tag"
  display_name         = "Require ${var.required_tag_name} tag (${local.name_base})"
  resource_group_id    = azurerm_resource_group.lab.id
  policy_definition_id = local.policy_require_tag
  enforce              = var.policy_enforcement

  parameters = jsonencode({
    tagName = {
      value = var.required_tag_name
    }
  })

  non_compliance_message {
    content = "Add a ${var.required_tag_name} tag to this resource."
  }
}
