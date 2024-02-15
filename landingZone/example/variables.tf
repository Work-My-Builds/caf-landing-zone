#variable "subscription_id" {
#  type = string
#  default = "b07c6415-3b3e-4968-9c83-5f2218fd57fe"
#}

variable "location" {
  type    = string
  default = "centralus"
}

variable "prefix" {
  type        = string
  default     = "vumc"
  description = "Prefix of the name of the all resources"
}