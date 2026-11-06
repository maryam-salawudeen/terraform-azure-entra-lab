variable "name" {
  description = "Storage account name. 3 to 24 lowercase letters and numbers, unique across Azure."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account names must be 3 to 24 lowercase letters or numbers."
  }
}

variable "resource_group_name" {
  description = "Resource group to create the storage account in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "shared_access_key_enabled" {
  description = "Allow access with storage account keys."
  type        = bool
  default     = true
}

variable "soft_delete_days" {
  description = "Days to keep deleted blobs and containers before they are gone for good."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
