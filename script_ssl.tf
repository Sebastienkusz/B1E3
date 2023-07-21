locals {
  scripts_path                 = "${path.module}/scripts/"
  ssl_cert_auth_script_name    = "auth-host.sh"
  ssl_cert_cleanup_script_name = "cleanup-host.sh"
  ssl_cert_script_name         = "ssl-cert.sh"
}

# Create the script that will upload the SSL certificate token
resource "local_file" "script_ssl_cert_auth" {
  filename        = "${local.scripts_path}${local.ssl_cert_auth_script_name}"
  file_permission = "0744"
  content         = <<-EOF
  #!/bin/bash

  echo $${CERTBOT_VALIDATION} > ./$${CERTBOT_TOKEN}
  az storage blob upload \
     --account-name ${azurerm_storage_account.key_storage.name} \
     -c ${azurerm_storage_container.container.name} \
     -n .well-known/acme-challenge/$${CERTBOT_TOKEN} \
     -f $${CERTBOT_TOKEN} \
     --only-show-errors 2>&1 > /dev/null
  EOF
}

# Create the script that will clean up the SSL certificate token
resource "local_file" "script_ssl_cert_cleanup" {
  filename        = "${local.scripts_path}${local.ssl_cert_cleanup_script_name}"
  file_permission = "0744"
  content         = <<-EOF
  #!/bin/bash

  rm -rf ./$${CERTBOT_TOKEN}
  az storage blob delete \
     --account-name ${azurerm_storage_account.key_storage.name} \
     -c ${azurerm_storage_container.container.name} \
     -n .well-known/acme-challenge/$${CERTBOT_TOKEN} \
     --only-show-errors 2>&1 > /dev/null
  EOF
}

locals {
  ssl_contact_email      = "jlabat@simplonformations.onmicrosoft.com"
  ssl_certbot_dir        = "${path.module}/certbot"
  ssl_certbot_config_dir = "${local.ssl_certbot_dir}/config"
  ssl_certbot_logs_dir   = "${local.ssl_certbot_dir}/logs"
  ssl_certbot_work_dir   = "${local.ssl_certbot_dir}/work"
  ssl_cert_pfx_path      = "${path.module}/cert.pfx"
}

# Create the script that will generate the SSL certificate
# The script will be executed by the provisioner "local-exec" in the file ssl-cert.tf
resource "local_file" "script_ssl_cert" {
  filename        = "${local.scripts_path}${local.ssl_cert_script_name}"
  file_permission = "0744"
  content         = <<-EOF
  #!/bin/bash -x

  certbot certonly \
          --test-cert \
          --non-interactive \
          --agree-tos \
          --manual \
          --config-dir=${local.ssl_certbot_config_dir} \
          --logs-dir=${local.ssl_certbot_logs_dir} \
          --work-dir=${local.ssl_certbot_work_dir} \
          --email ${local.ssl_contact_email} \
          --preferred-challenges=http \
          --manual-auth-hook ${local_file.script_ssl_cert_auth.filename} \
          --manual-cleanup-hook ${local_file.script_ssl_cert_cleanup.filename} \
          -d ${azurerm_public_ip.Public_IP_Appli.fqdn} > /dev/null

  openssl pkcs12 -export \
          -out ${local.ssl_cert_pfx_path} \
          -inkey ${local.ssl_certbot_config_dir}/live/${azurerm_public_ip.Public_IP_Appli.fqdn}/privkey.pem \
          -in ${local.ssl_certbot_config_dir}/live/${azurerm_public_ip.Public_IP_Appli.fqdn}/fullchain.pem \
          -passout pass:"$${SSL_PASSWD}" > /dev/null

  az keyvault certificate import --vault-name ${azurerm_key_vault.coffre_fort.name} \
          -f ${local.ssl_cert_pfx_path} \
          -n ${local.appli_name} \
          --password "$${SSL_PASSWD}" > /dev/null
  EOF
}

# To convert the PEM certificate in PFX we need a password
resource "random_password" "ssl_cert" {
  length           = 24
  override_special = "!@#%&*()-_+:?"
}

# The script will be executed by the provisioner "local-exec"
# The provisioner will be executed when the public IP's FQDN is created or updated
resource "null_resource" "ssl_cert" {
  depends_on = [
    azurerm_key_vault_access_policy.ssl,
    #azurerm_application_gateway.app
  ]
  triggers = {
    fqdn = azurerm_public_ip.Public_IP_Appli.fqdn
  }
  provisioner "local-exec" {
    command = local_file.script_ssl_cert.filename
    environment = {
      SSL_PASSWD = random_password.ssl_cert.result
    }
  }
}