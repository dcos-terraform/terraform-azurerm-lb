output "elb_address" {
  value = "${element(concat(azurerm_public_ip.master_load_balancer_public_ip.*.fqdn,
                            azurerm_public_ip.public_agent_load_balancer_public_ip.*.fqdn,
                            list("")), 0)}"
}
