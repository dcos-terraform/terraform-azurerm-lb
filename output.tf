# LB Address
output "elb_address" {
  value = "${element(concat(azurerm_public_ip.master_load_balancer_public_ip.*.fqdn,
                            azurerm_public_ip.public_agent_load_balancer_public_ip.*.fqdn,
                            list("")), 0)}"
}

# Public backend address pool ID
output "public_backend_address_pool" {
  value = "${element(concat(azurerm_lb_backend_address_pool.public_master_backend_pool.*.id,
                            azurerm_lb_backend_address_pool.external_public_agent_backend_pool.*.id,
                            list("")), 0)}"
}

# Private backend address pool ID
output "private_backend_address_pool" {
  value = "${element(concat(azurerm_lb_backend_address_pool.private_master_backend_pool.*.id,
                            list("")), 0)}"
}
