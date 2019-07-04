[![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/buildStatus/icon?job=dcos-terraform%2Fterraform-azurerm-lb%2Fsupport%252F0.2.x)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/support%252F0.2.x/)

Azure LB
============
The module creates Load Balancers on AzureRM

EXAMPLE
-------

```hcl
module "dcos-lbs" {
  source  = "dcos-terraform/lb/azurerm"
  version = "~> 0.2.0"

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
| cluster\_name | Name of the DC/OS cluster | string | n/a | yes |
| instance\_nic\_ids | List of instance nic ids created by this module | list | n/a | yes |
| ip\_configuration\_names | List of ip configuration names associated with the instance nic ids | list | n/a | yes |
| location | Azure Region | string | n/a | yes |
| num | How many instances should be created | string | n/a | yes |
| resource\_group\_name | Name of the azure resource group | string | n/a | yes |
| additional\_rules | List of additional rules | list | `<list>` | no |
| internal | This ELB is internal only | string | `"false"` | no |
| lb\_name\_format | Printf style format for naming the LB. (input cluster_name) | string | `"lb-%[1]s"` | no |
| name\_prefix | Name Prefix | string | `""` | no |
| probe | Main probe to check for node health | map | `<map>` | no |
| rules | List of rules. By default HTTP and HTTPS are set. If set it overrides the default rules. | list | `<list>` | no |
| subnet\_id | Subnet ID | string | `""` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend\_address\_pool | backend address pool |
| lb\_address | lb address |

