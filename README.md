[![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/master/)
# azurerm lb
The module creates Load Balancers on AzureRM


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dcos_role | dcos role | string | - | yes |
| hostname_format | Format the hostname inputs are index+1, region, cluster_name | string | `lb-%[1]s` | no |
| location | location | string | - | yes |
| name_prefix | Cluster Name | string | - | yes |
| resource_group_name | resource group name | string | - | yes |
| subnet_id | Subnet ID | string | `` | no |
| tags | Add custom tags to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| elb_address | LB Address |
| private_backend_address_pool | Private backend address pool ID |
| public_backend_address_pool | Public backend address pool ID |

