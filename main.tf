/**
 * [![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/buildStatus/icon?job=dcos-terraform%2Fterraform-azurerm-lb%2Fsupport%252F0.2.x)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-azurerm-lb/job/support%252F0.2.x/)
 *
 * Azure LB
 * ============
 * The module creates Load Balancers on AzureRM
 *
 * EXAMPLE
 * -------
 *
 *```hcl
 * module "dcos-lbs" {
 *   source  = "dcos-terraform/lb/azurerm"
 *   version = "~> 0.2.0"
 *
 *   cluster_name = "production"
 *
 *   location = "North Europe"
 *   resource_group_name = "my-resource-group"
 *   additional_rules = [{
 *      frontend_port = 8080
 *      backend_port  = 80
 *   }]
 * }
 *```
 */

provider "azurerm" {
  version = "~> 2.0"
  features {}
}

locals {
  cluster_name = var.name_prefix != "" ? "${var.name_prefix}-${var.cluster_name}" : var.cluster_name
  lb_name      = format(var.lb_name_format, local.cluster_name)
  merged_tags = merge(
    var.tags,
    {
      "Name" = local.lb_name
    },
    {
      "Cluster" = local.cluster_name
    },
  )

  default_rules = [
    {
      frontend_port           = 80
      idle_timeout_in_minutes = 4
      protocol                = "Tcp"
    },
    {
      frontend_port           = 443
      idle_timeout_in_minutes = 4
      protocol                = "Tcp"
    },
  ]

  final_rules = coalescelist(var.rules, concat(local.default_rules, var.additional_rules))
}

resource "azurerm_public_ip" "public_ip" {
  count               = var.num == 0 ? 0 : var.internal ? 0 : 1
  name                = "${local.lb_name}-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "${local.lb_name}-ip"

  tags = local.merged_tags
}

# Front End Load Balancer
resource "azurerm_lb" "load_balancer" {
  count               = var.num == 0 ? 0 : 1
  name                = local.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "${local.lb_name}-public-ip-config"
    public_ip_address_id          = var.internal ? "" : element(concat(azurerm_public_ip.public_ip.*.id, [""]), 0)
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.internal ? var.subnet_id : ""
  }

  tags = local.merged_tags
}

# Back End Address Pool for Public and Private Loadbalancers
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  count               = var.num == 0 ? 0 : 1
  name                = "${local.lb_name}-public_backend_address_pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.load_balancer[0].id
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  count                = length(var.instance_nic_ids)
  network_interface_id = element(var.instance_nic_ids, count.index)
  ip_configuration_name = replace(
    element(
      split("/", element(var.instance_nic_ids, count.index)),
      length(split("/", element(var.instance_nic_ids, count.index))) - 1,
    ),
    "-nic",
    "-ipConfig",
  )
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool[0].id
}

# Load Balancer Rule
resource "azurerm_lb_rule" "load_balancer_rule" {
  for_each            = { for r in local.final_rules : r["frontend_port"] => r }
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.load_balancer[0].id

  name          = "load-balancer-rule-${each.key}"
  protocol      = lookup(each.value, "protocol", "Tcp")
  frontend_port = each.key
  backend_port = lookup(
    each.value,
    "backend_port",
    each.key,
  )
  idle_timeout_in_minutes = lookup(each.value, "idle_timeout_in_minutes", 4)

  frontend_ip_configuration_name = "${local.lb_name}-public-ip-config"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_pool[0].id
  probe_id                       = azurerm_lb_probe.load_balancer_http_probe[0].id
  depends_on                     = [azurerm_lb_probe.load_balancer_http_probe]
}

resource "azurerm_lb_probe" "load_balancer_http_probe" {
  count               = var.num == 0 ? 0 : 1
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.load_balancer[0].id
  name                = "${local.lb_name}-probe"

  port                = lookup(var.probe, "port", 80)
  protocol            = lookup(var.probe, "protocol", "TCP")
  request_path        = lookup(var.probe, "request_path", "")
  interval_in_seconds = lookup(var.probe, "interval_in_seconds", 30)
  number_of_probes    = lookup(var.probe, "number_of_probes", 2)
}
