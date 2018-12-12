[![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/master/)

Azure LB
============
The module creates Load Balancers on AzureRM

EXAMPLE
-------

```hcl
module "dcos-lbs" {
  source  = "dcos-terraform/lb/azurerm"
  version = "~> 0.1.0"

  cluster_name = "production"

  location = "North Europe"
  resource_group_name = "my-resource-group"
  additional_rules = [{
     frontend_port = 8080
     backend_port  = 80
  }]
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_rules | List of additional rules | string | `<list>` | no |
| cluster_name | Name of the DC/OS cluster | string | - | yes |
| internal | This ELB is internal only | string | `false` | no |
| lb_name_format | Printf style format for naming the LB. (input cluster_name) | string | `lb-%[1]s` | no |
| location | Azure Region | string | - | yes |
| probe | Main probe to check for node health | map | `<map>` | no |
| resource_group_name | Name of the azure resource group | string | - | yes |
| rules | List of rules. By default HTTP and HTTPS are set. If set it overrides the default rules. | string | `<list>` | no |
| subnet_id | Subnet ID | string | `` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend_address_pool | Public backend address pool ID |
| lb_address | LB Address |

