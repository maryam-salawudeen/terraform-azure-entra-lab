# Remote state (optional)
#
# By default this project uses local state (a terraform.tfstate file in this
# folder). That is fine for a personal lab and needs no setup.
#
# For a team, state should live somewhere shared and locked. On Azure that is a
# storage account blob container. Create the storage account once by hand or
# with a separate bootstrap config, then uncomment the block below, fill in the
# names, and run:
#
#   terraform init -migrate-state
#
# use_azuread_auth = true makes Terraform read and write state with your Entra
# ID login instead of a storage account key. Your account needs the
# "Storage Blob Data Contributor" role on the container.
#
# The azurerm backend locks state with a blob lease, so two people cannot run
# apply at the same time.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-tfstate"
#     storage_account_name = "sttfstateCHANGEME"
#     container_name       = "tfstate"
#     key                  = "terraform-azure-entra-lab.tfstate"
#     use_azuread_auth     = true
#   }
# }
