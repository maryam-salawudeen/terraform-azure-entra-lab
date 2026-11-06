variable "display_name" {
  description = "Display name of the Entra ID security group."
  type        = string
}

variable "description" {
  description = "What the group is for. Shows up in the Entra admin center."
  type        = string
}

variable "owners" {
  description = "Object IDs of the group owners."
  type        = list(string)
  default     = []
}

variable "role_assignments" {
  description = "Azure RBAC roles to give the group. The map key is any short label, used only to keep Terraform addresses stable."
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default = {}
}
