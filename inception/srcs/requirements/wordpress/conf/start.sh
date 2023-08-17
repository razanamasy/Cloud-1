#!/bin/bash

export wppath="/var/www/html"

sleep 10

# Execute WordPress setup commands if wp not install exist
yes | wp core download --allow-root --path="$wppath"

cd $wppath
wp config create --dbpass=$MYSQL_DB_PASS --path="$wppath" --allow-root --dbname=hina_db --dbuser=hina --dbhost=$RDS_ENDPOINT --config-file="$wppath/wp-config.php"
wp core install --allow-root --path="$wppath" --url="hrazanam.net" --title="coucou" --admin_name=super --admin_password=$ADMIN_PASS --admin_email=hina.razanamasy@gmail.com --skip-email
wp user create --allow-root --path="$wppath" user user@example.com --role=author --user_pass=$ADMIN_PASS

exec php-fpm7.3 -F
