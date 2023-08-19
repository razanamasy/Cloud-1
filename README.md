<h3 align="center">Cloud1</h3>

<!-- ABOUT THE PROJECT -->
## PROJET EN COURS

## Pre-requis
#### Installation
aws cli
user IAM → à référer dans awscli configuration
Terraform
Ansible

#### MY IP
Ne pas oublier de changer myip dans les security-group instance
Pair de clé 
créer keypair pour ec2 avec le bon nom et mettre dans dossier cloud-terraform
Recuperation du nom des subnets dans votre console AWS

#### Nom de domaine et certificat ACM
1) Acheter un nom de domain (ici hrazanam.net) avec route 53 → ne pas oublier de l’indiquer dans le fichier wordpress start.sh.
	→ Nécessaire car certificat ACM ne marche pas avec domaine AWS

2) Générer un certificat ssl ACM avec hrazanam.net <sup>(*)</sup>

##### note 1 : Affiliation du certificat au LB est automatisé avec terraform 

##### note 2 : L’enregistrement DNS du LB a hrazanam est automatisé avec terraform 

###### <sup>(*)</sup> Si le certificat est en pending : 
CMD : dig +short hrazanam.net <br>
https://repost.aws/fr/knowledge-center/acm-certificate-pending-validation
La commande permet d'obtenir la valeur associée à l'enregistrement CNAME si ce dernier a été ajouté à la bonne configuration DNS, et propagé avec succès.

## Techno
### Docker-compose
### AWS
### Terraform

## Ressources AWS 
### Loadbalancer Applicatif
### Instance EC2
### AMI from instance & Template
### Target group / Autoscaling group
### EFS
### RDS
### ACM
