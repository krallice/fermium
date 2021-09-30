output "pip" {
  description = "Public IP Address of Virtual Machines."
  value       = ["${azurerm_public_ip.publicip.*.ip_address}"]
}

# output "pip-1" {
# description = "Public IP Address of Virtual Machine"
# value       = azurerm_public_ip.publicip.1.ip_address
# }
