variable "subscription_id" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the all resources"
}

variable "business_code" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "vulnerabilityAssessmentsEmail" {
  type    = string
  default = ""
}

variable "emailSecurityContact" {
  type    = string
  default = ""
}
