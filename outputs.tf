output "lb_address" {
  description = "lb address"
  value = var.internal ? element(
    concat(azurerm_lb.load_balancer.*.private_ip_address, [""]),
    0,
  ) : element(concat(azurerm_public_ip.public_ip.*.fqdn, [""]), 0)
}

output "backend_address_pool" {
  description = "backend address pool"
  value = element(
    concat(azurerm_lb_backend_address_pool.backend_pool.*.id, [""]),
    0,
  )
}

