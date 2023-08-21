<h3 align="center">Cloud1</h3>

<!-- ABOUT THE PROJECT -->
## PROJET EN FINALISATION

## Pre-requis
#### Installation
aws cli
user IAM → à référer dans awscli configuration
Terraform
Ansible

#### MY IP
Ne pas oublier de changer myip dans les security-group instance
Pair de clé 
créer keypair pour ec2 avec le bon nom et mettre dans dossier cloud-terraform ET ansible
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
Docker-compose <br>
AWS <br>
Terraform <br>

## Ansible dynamic inventory
Utilisation de Ansible pour docker-compose start et stop sur les instance eu-west-3 <br>
Les instance sont dynamiquement detectées <br>
La commande: ansible-inventory -i aws_ec2.yaml --graph permet de lister les instances target <br>

Ne pas oublier la key-pair (voir pré-requis) <br>

## Ressources AWS 
Loadbalancer Applicatif <br>
Instance EC2 <br>
AMI from instance & Template <br>
Target group / Autoscaling group <br>
EFS <br>
RDS <br>
ACM <br>
Route53 <br>

## Usage
Après avoir vérifié les pré-requis, (installations, IAM user, key-pair, nom de domaine, ip security group...) aller dans le dossier cloud-terraform <br>

### Création et deploiement de l'architecture
terraform init <br>
terraform validate <br>
terraform plan <br>
terraform apply | yes <br>

### Test ansible
ansible-playbook -i aws_ec2.yaml docker_playbook.yaml --user ubuntu --key-file <br>
wp-keypair-mac.pem --tags stop <br>
ansible-playbook -i aws_ec2.yaml docker_playbook.yaml --user ubuntu --key-file <br>
wp-keypair-mac.pem --tags start <br>

