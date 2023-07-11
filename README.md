<h3 align="center">Inception</h3>

<!-- ABOUT THE PROJECT -->

Ce projet à l’école 42, m’a permis de découvrir docker, docker-compose, le concept de containérisation ainsi que le fonctionnement d’une application wordpress. J'y ai également vu des notions de networking, nécessaires pour faire communiquer les containers entre eux.J’ai mis en place 3 services containérisés, au sein du même network défini dans le docker-compose.yaml.

L’application n’est accessible que depuis le port 443, correspondant au port d’écoute HTTPS où écoute mon server NGINX. (Pour le test un certificat auto-signé est généré par OpenSSL). Le serveur est configuré tel que: si la requête contient des éléments php elle seront redirigées vers le gestionnaire de processus php, PHP-FPM situé dans le container wordpress (en écoute sur le port 9000). Un système de volume partagé entre les containers wordpress et nginx est mis en place afin que nginx puisse récupérer tous les fichiers wordpress situé dans /var/www/html. Ces même fichiers sont stockés dans la machine parent (fichier renseigné dans le docker-compose.yaml, selon la machine) Enfin dans le container wordpress je définis le user de la database qui communiquera avec le server db mariadb. Le nom du user et de la db , sont ceux créés du côté container Mariadb.

### Installation
Depuis la racine
#### $ make
