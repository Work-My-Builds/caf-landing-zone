variable "root_scope_resource_id" {
  type    = string
  default = ""
}

variable "child_management_groups" {
  type    = list(string)
  default = []
}

variable "location" {
  type = string
}

variable "enable_policy_definitions" {
  type    = bool
  default = false
}

variable "enable_policy_assignments" {
  type    = bool
  default = false
}