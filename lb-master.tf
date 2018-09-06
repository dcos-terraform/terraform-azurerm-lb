# Public IP addresses for the Public Front End load Balancer
resource "azurerm_public_ip" "master_load_balancer_public_ip" {
  name                         = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-master-lb-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "master-pub-lb-${format(var.hostname_format, count.index + 1, var.name_prefix)}"

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Public IP addresses for the Public Front End load Balancer
resource "azurerm_public_ip" "master_public_ip" {
  count                        = "${var.dcos_role == "master" ? 1 : 0 }"
  count                        = "${var.num_of_masters}"
  name                         = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-master-pub-ip-${count.index + 1}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-master-${count.index + 1}"

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Front End Load Balancer
resource "azurerm_lb" "master_public_load_balancer" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-pub-mas-elb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                 = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-ip-config"
    public_ip_address_id = "${azurerm_public_ip.master_load_balancer_public_ip.id}"
  }

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Internal Private Front End Load Balancer
resource "azurerm_lb" "master_internal_load_balancer" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-int-master-elb"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
    subnet_id                     = "${var.network_security_group_id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${merge(var.tags, map("Name", format(var.hostname_format, (count.index + 1), var.location, var.name_prefix),
                                "Cluster", var.name_prefix))}"
}

# Back End Address Pool for Public and Private Loadbalancers
resource "azurerm_lb_backend_address_pool" "public_master_backend_pool" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public_backend_address_pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.master_public_load_balancer.id}"
}

# Back End Address Pool for Private Loadbalancers
resource "azurerm_lb_backend_address_pool" "private_master_backend_pool" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  name                = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-internal_backend_address_pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.master_internal_load_balancer.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "public_load_balancer_http_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_public_load_balancer.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public_master_backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.load_balancer_http_probe.id}"
  depends_on                     = ["azurerm_lb_probe.load_balancer_http_probe"]
}

# Load Balancer Rule
resource "azurerm_lb_rule" "public_load_balancer_https_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_public_load_balancer.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-public-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public_master_backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.load_balancer_https_probe.id}"
  depends_on                     = ["azurerm_lb_probe.load_balancer_https_probe"]
}

# Load Balancer Rule
resource "azurerm_lb_rule" "private_load_balancer_http_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_internal_load_balancer.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.private_master_backend_pool.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "private_load_balancer_https_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_internal_load_balancer.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.private_master_backend_pool.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "private_load_balancer_mesos_http_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_internal_load_balancer.id}"
  name                           = "MesosHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 5050
  backend_port                   = 5050
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.private_master_backend_pool.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "private_load_balancer_exhibitor_http_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_internal_load_balancer.id}"
  name                           = "ExhibitorHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 8181
  backend_port                   = 8181
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.private_master_backend_pool.id}"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "private_load_balancer_marathon_https_rule" {
  count                          = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.master_internal_load_balancer.id}"
  name                           = "MarathonHTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "${format(var.hostname_format, count.index + 1, var.name_prefix)}-private-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.private_master_backend_pool.id}"
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "load_balancer_http_probe" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.master_public_load_balancer.id}"
  name                = "HTTP"
  port                = "80"
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "load_balancer_https_probe" {
  count               = "${var.dcos_role == "master" ? 1 : 0 }"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.master_public_load_balancer.id}"
  name                = "HTTPS"
  port                = "443"
}
