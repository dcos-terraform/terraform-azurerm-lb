# Cluster Name
variable "name_prefix" {}

# Format the hostname inputs are index+1, region, name_prefix
variable "hostname_format" {
  default = "lb-%[1]s"
}

# Name of the azure resource group
variable "resource_group_name" {}

# Subnet ID
variable "subnet_id" {
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
