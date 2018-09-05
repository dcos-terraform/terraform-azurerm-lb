# Cluster Name
variable "name_prefix" {}

# Format the hostname inputs are index+1, region, name_prefix
variable "hostname_format" {
  default = "nsg-%[1]d-%[2]s"
}

# Name of the azure resource group
variable "resource_group_name" {}

# Security Group Id
variable "network_security_group_id" {
  default = ""
}

# Specify dcos role for nsg configuration
variable "dcos_role" {}

# Location (region)
variable "location" {}

# Add special tags to the resources created by this module
variable "tags" {
  type    = "map"
  default = {}
}
