# Entra ID security groups and the Azure roles they get.
#
# Each group gets the smallest built-in role that fits its job, scoped to the
# narrowest resource that works: the resource group, the storage account or
# the vault. Nothing here is assigned at subscription scope, and no group gets
# Owner or User Access Administrator.

locals {
  # The person or service principal running Terraform owns the groups.
  group_owners = [data.azuread_client_config.current.object_id]
}

# Can see everything in the resource group, change nothing.
module "group_readers" {
  source = "./modules/entra-group-rbac"

  display_name = "sg-${local.name_base}-readers"
  description  = "Read-only access to the ${azurerm_resource_group.lab.name} resource group."
  owners       = local.group_owners

  role_assignments = {
    rg_reader = {
      scope                = azurerm_resource_group.lab.id
      role_definition_name = "Reader"
    }
  }
}

# Can read and write blob data in the lab storage account, but cannot change
# the account's settings, keys or network rules.
module "group_storage_operators" {
  source = "./modules/entra-group-rbac"

  display_name = "sg-${local.name_base}-storage-operators"
  description  = "Blob data read/write on the lab storage account only."
  owners       = local.group_owners

  role_assignments = {
    rg_reader = {
      scope                = azurerm_resource_group.lab.id
      role_definition_name = "Reader"
    }
    blob_data_contributor = {
      scope                = module.storage.id
      role_definition_name = "Storage Blob Data Contributor"
    }
  }
}

# Apps or people that only need to read secret values. They cannot create,
# change or delete secrets, and cannot touch keys or certificates.
module "group_kv_secret_readers" {
  source = "./modules/entra-group-rbac"

  display_name = "sg-${local.name_base}-kv-secret-readers"
  description  = "Read secret values in the lab Key Vault."
  owners       = local.group_owners

  role_assignments = {
    kv_secrets_user = {
      scope                = azurerm_key_vault.lab.id
      role_definition_name = "Key Vault Secrets User"
    }
  }
}
