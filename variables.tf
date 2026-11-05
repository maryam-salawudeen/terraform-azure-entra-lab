variable "subscription_id" {
  description = "Azure subscription to deploy into. Leave null to use the ARM_SUBSCRIPTION_ID environment variable."
  type        = string
  default     = null
}

variable "prefix" {
  description = "Short name used at the start of resource names."
  type        = string
  default     = "entralab"

  validation {
    condition     = can(regex("^[a-z0-9]{3,10}$", var.prefix))
    error_message = "prefix must be 3 to 10 lowercase letters or numbers, because it ends up in storage account and Key Vault names."
  }
}

variable "environment" {
  description = "Environment label used in names and tags."
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "canadacentral"
}

variable "allowed_locations" {
  description = "Regions the Azure Policy assignment allows inside the resource group. Must include var.location."
  type        = list(string)
  default     = ["canadacentral", "canadaeast"]
}

variable "owner_tag" {
  description = "Value for the Owner tag. Use a name or team, not an email address."
  type        = string
  default     = "lab-owner"
}

variable "tags" {
  description = "Extra tags to merge onto every resource."
  type        = map(string)
  default     = {}
}

variable "required_tag_name" {
  description = "Tag name that the 'Require a tag on resources' policy enforces in the resource group."
  type        = string
  default     = "Owner"
}

variable "policy_enforcement" {
  description = "When false, policy assignments run in audit-only mode (DoNotEnforce)."
  type        = bool
  default     = true
}

variable "storage_shared_key_enabled" {
  description = "Allow storage account key access. Turning it off is more secure, but your account then needs Storage data-plane RBAC roles for Terraform to manage the account."
  type        = bool
  default     = true
}

variable "key_vault_purge_protection" {
  description = "Enable purge protection on the Key Vault. Off by default so the lab can be destroyed and recreated. Turn it on for anything real."
  type        = bool
  default     = false
}

variable "enable_conditional_access" {
  description = "Create a report-only Conditional Access policy. Needs Entra ID P1 and the Policy.ReadWrite.ConditionalAccess permission, so it is off by default."
  type        = bool
  default     = false
}
