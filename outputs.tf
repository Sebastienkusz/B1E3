output "gateway_frontend_ip" {
  value = "http://${azurerm_public_ip.Public_IP_Appli.ip_address}"
}