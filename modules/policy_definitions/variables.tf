variable "root_scope_resource_id" {
  type    = string
  default = ""
}

variable "management_group_id" {
  type    = string
  default = ""
}

variable "location" {
  type = string
}

variable "enable_policy_definitions" {
  type    = bool
  default = false
}