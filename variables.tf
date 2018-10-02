variable "cluster_name" {
  description = "Name of the DC/OS cluster"
}

# Format the hostname inputs are index+1, region, name_prefix
variable "lb_name_format" {
  description = "Printf style format for naming the LB. (input cluster_name)"
  default     = "lb-%[1]s"
}

# Name of the azure resource group
variable "resource_group_name" {
  description = "resource group name"
}

# Location (region)
variable "location" {
  description = "Azure location"
}

variable "tags" {
  description = "Add custom tags to all resources"
  type        = "map"
  default     = {}
}

variable "probe" {
  description = "Main probe to check for node health"
  type        = "map"

  default = {
    number_of_probes    = 2
    timeout             = 3
    protocol            = "TCP"
    port                = 80
    interval_in_seconds = 30
  }
}

variable "rules" {
  description = "List of rules. By default HTTP and HTTPS are set. If set it overrides the default listeners."
  default     = []
}

variable "additional_rules" {
  description = "List of additional rules"
  default     = []
}
