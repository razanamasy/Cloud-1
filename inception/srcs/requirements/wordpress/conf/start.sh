#!/bin/bash

wppath="/var/www/html"

sleep 10


# Check if the WordPress website already exists
if wp core is-installed --allow-root --path="$wppath"; then
    echo "WordPress website already exists. Skipping setup."
else
    # Execute WordPress setup commands

	yes | wp core download --allow-root --path="$wppath" 
	ls -la "$wppath"
    wp config create --dbpass=$MYSQL_DB_PASS --path="$wppath" --allow-root --dbname=hina_db --dbuser=hina --dbhost=wp-db-rds.co07wcketazs.eu-west-3.rds.amazonaws.com --config-file="$wppath/wp-config.php"
    wp core install --allow-root --path="$wppath" --url=wp-lb-1725320114.eu-west-3.elb.amazonaws.com --title="coucou" --admin_name=super --admin_password=$ADMIN_PASS --admin_email=hina.razanamasy@gmail.com --skip-email
    wp user create --allow-root --path="$wppath" user user@example.com --role=author --user_pass=$ADMIN_PASS
fi

exec php-fpm7.3 -F
