# LB Address
output "lb_address" {
  description = "lb address"

  value = "${azurerm_public_ip.public_ip.fqdn}"
}

# Public backend address pool ID
output "backend_address_pool" {
  description = "backend address pool"

  value = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}
