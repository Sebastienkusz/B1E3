# b1e3-gr2
## Introduction

Avant de commencer, on peut supprimer les liaisons ssh si elles existent

>`ssh-keygen -f "$HOME/.ssh/known_hosts" -R "b1e3-gr2-bastion.westeurope.cloudapp.azure.com"`

>`ssh-keygen -f "$HOME/.ssh/known_hosts" -R "10.1.0.4"`

>`ssh-keygen -f "$HOME/.ssh/known_hosts" -R "10.1.0.5"`


### 1- Lancer le terraform depuis le dossier de base.

Si terraform est déjà déployé par un collègue, il faut lancer un terraform pour générer certains fichiers :

>```terraform apply -target local_file.inventaire -target local_file.script_ssh_config -target local_file.admin_rsa_file -target local_file.update_gitignore```

### 2- Lancer les scripts

se placer dans le dossier scripts

NOTE : Le lancement de script_init.sh installe __dos2unix__ qui permet de formater les scripts générés.

>```./script_init.sh```

>```./update_gitignore.sh```

>```./script_ansible.sh```

Option possible pour un confort d'utilisation :

On crée des raccourcis dans le fichier config pour faciliter les accès
Ajout de configuration dans le ~/.ssh/config
pour avoir des raccourcis vers les VM
>```ssh bastion```

>```ssh appli```

pour cela, il suffit de lancer la commande

>```./add_ssh_config.sh -u toto -f ssh_key```

"u" étant le user

"f" étant le nom de fichier de la clé ssh privée correspondant à la clé se trouvant dans le dossier ssh_keys

### 3- Se placer dans le dossier ansible 

>```cd ansible```

Se placer dans un environnement virtuel pour installer ansible et tous les modules si nécessaires

>```virtualenv b1e3```
>```source b1e3/bin/activate```

installer __ansible__ :

vérifier la version de python puis 
>```pip3 install ansible```

Ajout des utilisateurs sur les 2 VM

>```ansible-playbook add-users.yml -i inventaire.ini```

Installation de la VM appli

>```ansible-playbook install-appli.yml -i inventaire.ini```


## Liste des ressources
- 1 **clé ssh** créé aléatoirement + Clés admins supplémentaires (Johann et Seb) 
- 1 **réseau virtuel** (b1e3-gr2-vn)
- 3 **sous-réseaux** (b1e3-gr2-sr1 /sr2) (b1e3-gr2-gateway)
- 3 **groupe de sécurité** (b1e3-gr2-nsg1/2/3) + **carte réseau** + **disques associés** 
- 1 **VM Linux** (Applicative) (b1e3-gr2-appli) 
- 1 **VM Linux** (Bastion) accés SSH (b1e3-gr2-bastion) 
- 1 **Azure Database** (MariaDB) (b1e3-gr2-bdd) 
- 1 **Azure DNS** (b1e3-gr2-dns) 
- 1 **compte de stockage** (disque de 5 go) (b1e3-gr2-storage) 
- 1 **Load balancer** (gateway)
- 1 **Azure Key Vault** (b1e3-gr2-keyvault) 
- 1 **conteneur** de stockage blob 
- 1 **Azure monitor** (b1e3-gr2-monitor) 
- 1 **Log analytics**
  
## Topologie
![topologie infrastructure](https://github.com/Simplon-AdminCloud-Bordeaux-2023-2025/b1e3-gr2/assets/132474933/2545d086-35ec-44cc-a23c-3b4083791c2e)
