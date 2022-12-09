# cluster-rke2 downstream de type vsphere
# 

# Objectif
Pouvoir créer un cluster vsphere via le cluster management rancher

# Préparation infrastructure vsphere
## storage policy sur le vcenter 
L'intérêt du storage policy est de pouvoir déclarer 1 seul storageclass, le scale du stockage se fera uniquement via vcenter sans impact sur la storageclass.

- sur le datastore shared storage ajout d'une balise `rke2`
strategie et profile, stockage , créer `rke-storage-policy` 

## Préparation template sles15
[modification template](./templatesles15sp3.md)

# Organisation du projet terraform
## Répertoire terraform

| `Fichier/Répertoire` | `Description` | 
| :------: |  :------: |
|  `.terrfaform`   | Inititalisation projet terraform commande `terraform init`.<br/>Download modules fichier `versions.tf`<br/> Répertoire dans `.gitignore`  | 
|  `versions.tf`   | Versions minimum pour chaque provider ici<br/> `vsphere`, `random`, `rancher2`, `template`  | 
|  `variables.tf`   | Définition du type des variables:<br/>`string`, `integer`, `list`..| 
|  `create_cluster_rke2.tf`   | définition de toutes les étapes pour: <br/> création cluster rke2<br/>machine pools`|
|  `machineconfig.tf`   | définition des configurations VM`|

## Répertoire env
Exemple avec l'environnement Test Intégration `vsphere-ti`   
**Important** le nom du répertoire sous `env/vsphere-ti` doit être identique à la valeur de la variable `environnement = vsphere-ti` dans le fichier `terraform.tfvars.

| `Répertoire` | `Fichiers` | `Description` | 
| :------: |  :------: | :------: |
|  `env`   | **N/A** | centralisation des environnements, backup terraform |
|  `env/vsphere-ti`| | |
| | **terraform.tfvars** | variables terraform pour création VM + cluster rke2 |
| | **terrform.tfstate** | **important** permet de garantir la cohérence du cluster TI |

## keys
contient les clé ssh pour se connecter au VM.
**TODO**: mettre les clé dans un vault

# Deploiement
Exemple avec un environnement `vsphere-ti`
**Avant de commencer mettre à jour les fichiers** :
- [terraform.tfvars](./env/vsphere-ti/terraform.tfvars)

```bash
# cd terraform; terraform init
# terraform apply -var-file ../env/vsphere-ti/terraform.tfvars -state=../env/vsphere-ti/terraform.tfstate -backup="-" -auto-approve
```
## Récupération du KUBECONFIG
A la fin de la création récupération du kubeconfig dans l'arborescence de ce projet sous `env/sphere-ti`



