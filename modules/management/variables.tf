variable "management_group_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "users" {
  type = map(string)
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the all resources"
}

variable "business_code" {
  type = string
}

variable "location" {
  type = string
}