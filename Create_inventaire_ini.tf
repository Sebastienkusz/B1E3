resource "local_file" "inventaire" {
  filename = "${path.module}/ansible/inventaire.ini"
  file_permission="0644"
  content  = <<-EOT
[bastion]
${azurerm_public_ip.Public_IP_Bastion.fqdn}

[appli]
${azurerm_linux_virtual_machine.VM_Appli.private_ip_address}

[bastion:vars]
ansible_port=${local.nsg_bastion_rule_sshport}
ansible_ssh_private_key_file=${tls_private_key.admin_rsa.public_key_openssh}

[appli:vars]
ansible_port=22
ansible_ssh_private_key_file=${tls_private_key.admin_rsa.public_key_openssh}
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q ${local.admin}@${azurerm_public_ip.Public_IP_Bastion.fqdn}"'

[bdd]

[all:vars]
ansible_connection=ssh
ansible_ssh_user=${local.admin}
ansible_become=true
EOT
}