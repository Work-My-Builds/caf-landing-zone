#variable "location" {
#  type = string
#}

variable "routes" {
  type    = any
  default = {}
}

variable "firewall_policies" {
  type    = any
  default = {}
}