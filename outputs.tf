# LB Address
output "lb_address" {
  description = "lb address"
  value       = "${var.internal ? azurerm_lb.load_balancer.private_ip_address : element(concat(azurerm_public_ip.public_ip.*.fqdn,list("")),0)}"
}

# Public backend address pool ID
output "backend_address_pool" {
  description = "backend address pool"
  value       = "${azurerm_lb_backend_address_pool.backend_pool.id}"
}
