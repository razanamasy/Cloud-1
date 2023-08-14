#!/bin/bash

wppath="/var/www/html"

# Check if the WordPress website already exists
if wp core is-installed --allow-root --path="$wppath"; then
    echo "WordPress website already exists. Skipping setup."
else
    # Execute WordPress setup commands

	export firsttime="yes"
	yes | wp core download --allow-root --path="$wppath" 
	ls -la "$wppath"
    wp config create --dbpass=$MYSQL_DB_PASS --path="$wppath" --allow-root --dbname=hina_db --dbuser=hina --dbhost=$RDS_ENDPOINT --config-file="$wppath/wp-config.php"
    wp core install --allow-root --path="$wppath" --url=$LOADBALANCER_DNS --title="coucou" --admin_name=super --admin_password=$ADMIN_PASS --admin_email=hina.razanamasy@gmail.com --skip-email
    wp user create --allow-root --path="$wppath" user user@example.com --role=author --user_pass=$ADMIN_PASS
fi

exec php-fpm7.3 -F
