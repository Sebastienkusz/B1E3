# Create tls private key 
resource "tls_private_key" "admin_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}