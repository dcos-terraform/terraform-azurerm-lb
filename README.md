# azurerm lb
The module creates Load Balancers on AzureRM

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dcos_role | Specify dcos role for nsg configuration | string | - | yes |
| hostname_format | Format the hostname inputs are index+1, region, name_prefix | string | `nsg-%[1]d-%[2]s` | no |
| location | Location (region) | string | - | yes |
| name_prefix | Cluster Name | string | - | yes |
| network_security_group_id | Security Group Id | string | - | yes |
| resource_group_name | Name of the azure resource group | string | - | yes |
| tags | Add special tags to the resources created by this module | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| elb_address |  |
