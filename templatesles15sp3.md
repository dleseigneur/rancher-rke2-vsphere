# Template linux sles15sp3

## Renommage du template sles15sp3 dans les vcenters 
nouveau nom **tsles15sp3** dans un dossier templates

## Intervention sur le template
tranformer le template en VM
Ajouter un Disque 3 de 200Go en mode Thin
Démarrer la VM


### modification paramètres système
```bash
# sysctl vm.max_map_count=262145
```
# Copie de la clé SSH
Copier le fichier ./keys/rkeid_rsa.pub en /root/.ssh/authorized_keys

# Ajout des AC 
Depuis un poste de travail linux :

```bash
# openssl x509 -in /usr/local/share/ca-certificates/MYCERT -text > MYAC.crt
# scp -i keys/rkeid_rsa MYAC.crt root@10.xx.xx.xx:/etc/pki/trust/anchors/
# ssh -i keys/rkeid_rsa root@10.xx.xx.xx
# update-ca-certificates
```

# Resize du vg rootvg
```bash
pvcreate /dev/sdc
vgextend rootvg /dev/sdc
lvextend -l +100%FREE /dev/rootvg/root
xfs_growfs /
```

# Invalider le SWAP
Mettre en commentaire la ligne concernant le SWAP dans le fichier /etc/fstab
### modification Bug wicked
Il faut supprimer les informations wicked pour garantir le dhcp avec un identifiant unique pour le DHCP
```bash
# rm /var/lib/wicked/*
```
# Installation de cloud-init en suspens

## installation cloud-init
```bash
# zypper in systemctl cloud-init cloud-init-config-suse
```
# Bug cloud-init :
L'activation de cloud-init ne fonctionne pas. Workaround 
```bash
# systemctl disable cloud-init.service cloud-final.service cloud-init-local.service cloud-config.service
# sed -i s/WantedBy=cloud-init.target/WantedBy=multi-user.target/ /usr/lib/systemd/system/cloud*.service
# systemctl enable cloud-init.service cloud-final.service cloud-init-local.service cloud-config.service
```

### Finalisation
Arrêt de la VM et remise en template.


