# Public IP addresses for the Public Front End load Balancer
resource "azurerm_public_ip" "public_agent_load_balancer_public_ip" {
  name                         = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-lb-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "public-agent-${format(var.hostname_format, count.index + 1, var.name_prefix)}"

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Front End Load Balancer
resource "azurerm_lb" "public_agent_public_load_balancer" {
  count               = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-pub-agent-elb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                 = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-agent-ip-config"
    public_ip_address_id = "${azurerm_public_ip.public_agent_load_balancer_public_ip.id}"
  }

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Back End Address Pool for Public and Private Loadbalancers
resource "azurerm_lb_backend_address_pool" "external_public_agent_backend_pool" {
  count               = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public_backend_address_pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_public_load_balancer.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "agent_public_load_balancer_http_rule" {
  count                          = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.public_agent_public_load_balancer.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-agent-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.external_public_agent_backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.agent_load_balancer_http_probe.id}"
  depends_on                     = ["azurerm_lb_probe.agent_load_balancer_http_probe"]
}

# Load Balancer Rule
resource "azurerm_lb_rule" "agent_public_load_balancer_https_rule" {
  count                          = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.public_agent_public_load_balancer.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-agent-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.external_public_agent_backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.agent_load_balancer_https_probe.id}"
  depends_on                     = ["azurerm_lb_probe.agent_load_balancer_https_probe"]
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "agent_load_balancer_http_probe" {
  count               = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_public_load_balancer.id}"
  name                = "HTTP"
  port                = 80
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "agent_load_balancer_https_probe" {
  count               = "${var.dcos_role == "public-agent" ? 1 : 0 }"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_public_load_balancer.id}"
  name                = "HTTPS"
  port                = 443
}
