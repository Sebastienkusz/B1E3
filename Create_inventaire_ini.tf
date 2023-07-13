# A modifier les private_keys

resource "local_file" "inventaire" {
  filename        = "${path.module}/ansible/inventaire.ini"
  file_permission = "0644"
  content         = <<-EOT
[bastion]
${azurerm_public_ip.Public_IP_Bastion.fqdn}

[appli]
${azurerm_linux_virtual_machine.VM_Appli.private_ip_address}

[bastion:vars]
ansible_port=${local.nsg_bastion_rule_sshport}
ansible_ssh_private_key_file="../${local_file.admin_rsa_file.filename}"

[appli:vars]
ansible_port=22
ansible_ssh_private_key_file="../${local_file.admin_rsa_file.filename}"
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q ${local.admin}@${azurerm_public_ip.Public_IP_Bastion.fqdn}"'

[bdd]

[all:vars]
ansible_connection=ssh
ansible_ssh_user=${local.admin}
ansible_become=true
ansible_python_interpreter="/usr/bin/python3"
EOT

  depends_on = [
    local_file.admin_rsa_file
  ]
}
