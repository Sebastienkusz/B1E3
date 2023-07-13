# b1e3-gr2
## Introduction

Avant de commencer, on peut supprimer les liaisons ssh si elles existent

    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "b1e3-gr2-bastion.westeurope.cloudapp.azure.com"
_____________
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "10.1.0.4"
_____________
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "10.1.0.5"


### 1- Lancement de Terraform

Si **terraform** est déjà déployé par un collègue, il faut lancer un **terraform apply** pour générer certains fichiers :

    terraform apply -target local_file.inventaire -target local_file.script_ssh_config -target local_file.admin_rsa_file -target local_file.update_gitignore

### 2- Lancement des scripts

Ensuite, on se place dans le dossier scripts

NOTE : Le lancement de **script_init.sh** installe **dos2unix** qui permet de formater les scripts générés.

    ./script_init.sh
________________
    ./update_gitignore.sh
________________
    ./script_ansible.sh

  #### *Option possible pour un confort d'utilisation :*

Il est possible de créer des raccourcis pour faciliter les accès. 

On peut ajouter la configuration dans le fichier **~/.ssh/config** pour avoir des raccourcis vers les VM.
>**ssh bastion**

>**ssh appli**

Pour cela, il suffit de lancer la commande suivante :

    ./add_ssh_config.sh -u toto -f ssh_key

"u" étant le user
"f" étant le nom de fichier de la clé ssh privée correspondant à la clé se trouvant dans le dossier ssh_keys

### 3- Lancement d'Ansible 
dans un premier temps, il faut se déplacer dans le dossier **ansible** avant de lancer les commandes ci-dessous
>cd ansible

Se placer dans un environnement virtuel pour installer **Ansible** et tous les modules si nécessaire

    virtualenv b1e3
_________
    source b1e3/bin/activate

  #### *Si Ansible n'est pas installé :*

  Vérifier d'abord la version de python et
  installer ensuite **Ansible** avec la commande ci-après :

    pip3 install ansible
    
Quand **Ansible** est installé, on lance les playbooks pour les configurations suivantes :

>Ajout des utilisateurs sur les 2 VM

    ansible-playbook add-users.yml -i inventaire.ini
    
>Installation de la VM appli

    ansible-playbook install-appli.yml -i inventaire.ini


## Liste des ressources
- 1 **clé ssh** créé aléatoirement + Clés admins supplémentaires (Johann et Seb) 
- 1 **réseau virtuel** (b1e3-gr2-vnet)
- 3 **sous-réseaux** (b1e3-gr2-sr1 /sr2) (b1e3-gr2-gw)
- 3 **groupe de sécurité** (b1e3-gr2-nsg1/2/3) + **carte réseau** + **disques associés** 
- 1 **VM Linux** (Applicative) (b1e3-gr2-appli) 
- 1 **VM Linux** (Bastion) accés SSH (b1e3-gr2-bastion) 
- 1 **Azure Database** (MariaDB) (b1e3-gr2-bdd)
- 1 **server mariadb** (b1e3-gr2-mariadbserver)
- 1 **Azure DNS** (b1e3-gr2-dns) 
- 1 **compte de stockage** (disque de 5 go) (b1e3-gr2-storage) 
- 1 **passerelle d'application** (b1e3-gr2-appgateway)
- 1 **Azure Key Vault** (b1e3-gr2-keyvault) 
- 1 **conteneur** de stockage blob 
- 1 **Azure monitor** (b1e3-gr2-monitor) 
- 1 **Log analytics** (b1e3-gr2-log)
  
## Topologie
![topologie infrastructure](https://github.com/Simplon-AdminCloud-Bordeaux-2023-2025/b1e3-gr2/assets/132474933/2545d086-35ec-44cc-a23c-3b4083791c2e)
