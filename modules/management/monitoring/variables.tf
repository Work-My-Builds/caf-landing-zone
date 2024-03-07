variable "subscription_id" {
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
