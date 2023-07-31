# b1e3-gr2
--------------------
### 1- Lancement de Terraform
Avant de lancer Terraform, penser à commenter les lignes **52 à 64** et **111 à 120** dans **gateway.tf** et la ligne **95** dans **script_ssl.tf**.
    
    terraform apply

Si **terraform** est déjà déployé par un collègue, il faut lancer un **terraform apply** pour générer certains fichiers :

    terraform apply -target local_file.inventaire -target local_file.script_ssh_config -target local_file.admin_rsa_file -target local_file.update_gitignore -target local_file.appli_commun_main_yml -target local_file.storage_main_yml
---------------------
### 2- Lancement des scripts

Ensuite, on se place dans le dossier scripts

NOTE : Le lancement de **script_init.sh** installe **dos2unix** qui permet de formater les scripts générés et supprimer les liaisons ssh si elles existent.

    ./script_init.sh


  #### *Option possible pour un confort d'utilisation :*

Il est possible de créer des raccourcis pour faciliter les accès. 

On peut ajouter la configuration dans le fichier **~/.ssh/config** pour avoir des raccourcis vers les VM.
>**ssh bastion**

>**ssh appli**

Pour cela, il suffit de lancer la commande suivante :

    ./add_ssh_config.sh -u toto -f ssh_key

"u" étant le user 

"f" étant le nom de fichier de la clé ssh privée correspondant à la clé se trouvant dans le dossier ssh_keys

## Warning
Après la création du certificat, penser à relancer un **terraform apply** sans oublier de décommenter les lignes suivantes: 
   
>lignes **52 à 64** et lignes **111 à 120** du fichier **gateway.tf**

>ligne **95** du fichier **script_ssl.tf**
-------------------------------  
### 3- Lancement d'Ansible 
Dans un premier temps, il faut se déplacer dans le dossier **ansible** avant de lancer les commandes ci-dessous
>cd ansible

Se placer dans un environnement virtuel pour installer **Ansible** et tous les modules si nécessaire

    virtualenv b1e3

    source b1e3/bin/activate

  #### *Si Ansible n'est pas installé :*

  Vérifier d'abord la version de python et
  installer ensuite **Ansible** avec la commande ci-après :

    pip3 install ansible
    
Quand **Ansible** est installé, on lance les playbooks pour les configurations suivantes :

>Installation de la VM Bastion

    ansible-playbook install-bastion.yml -i inventaire.ini
    
>Installation de la VM appli

    ansible-playbook install-appli.yml -i inventaire.ini

------------------
## Liste des ressources
- 1 **clé ssh** créé aléatoirement + Clés admins supplémentaires (Johann et Seb) 
- 1 **réseau virtuel** 			           (b1e3-gr2-vnet) 
- 1 **sous-réseau**				           (b1e3-gr2-sr1) 
- 1 **sous-réseau**				           (b1e3-sr2-sr2) 
- 1 **sous-réseau**				           (b1e3-gr2-gw) 
- 3 **NSG** 					           (b1e3-gr2-nsg-bastion/ "-”-"-mariadb / “-”-”- wiki-js)
- 1 **VM Linux (Applicative)** 		       (b1e3-gr2-appli) 
- 1 **VM Linux (Bastion)** 			       (b1e3-gr2-bastion) 
- 1 **Azure Database (MariaDB)** 		   (b1e3-gr2-mariadb) 
- 1 **Azure DNS** 				           (privatelink.mariadb.database.azure.com) 
- 1 **compte de stockage (5 go)** 		   (b1e3-gr2-wikistorage)   
- 1 **compte de stockage** 		           (b1e3gr2kv) 
- 1 **Load balancer (gateway)**		       (b1e3-gr2-gateway) 
- 1 **Azure Key Vault** 			       (b1e3-gr2-keyvault)		 
- 1 **Espace de travail Log analytics**    (b1e3-gr2-vm-wiki-js-workspace) 
- 1 **Classeur Azure**			           (b1e3-gr2-workbook) 
- 1 **groupe de machines identiques**	   (b1e3-gr2-scale) 
- 1 **Coffre Recovery Services**		   (b1e3gr2recoveryservicesvault)
-------------------- 
## Topologie
![shéma](https://github.com/Simplon-AdminCloud-Bordeaux-2023-2025/b1e3-gr2/assets/132474933/e75dc5e9-5e7f-4e14-a23c-a8b9fa4d5a53)


