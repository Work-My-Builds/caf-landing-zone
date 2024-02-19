variable "management_group_id" {
  type = string
}

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

variable "display_name" {
  type    = string
  default = "Configure backup on virtual machines without a given tag to an existing recovery services vault in the same location"
}

variable "description" {
  type    = string
  default = "Enforce backup for all virtual machines by backing them up to an existing central recovery services vault in the same location and subscription as the virtual machine. Doing this is useful when there is a central team in your organization managing backups for all resources in a subscription. You can optionally exclude virtual machines containing a specified tag to control the scope of assignment. See https://aka.ms/AzureVMCentralBackupExcludeTag."
}

variable "non_compliance_message" {
  type    = string
  default = "Backup on virtual machines without a given tag should be configured to an existing recovery services vault with specified backup policy or default policy."
}