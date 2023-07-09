# b1e3-gr2
## Introduction

Se placer dans le dossier ansible 

```$> ansible-playbook add-users.yml -i inventaire.ini```



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
