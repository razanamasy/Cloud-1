#!/bin/bash

#In case of corrupted database files ! if doesn't work, remove then
#command below, then chmod and chown again 
mysql_install_db --user=root --basedir=/usr --datadir=/var/lib/mysql

service mysql start
mysql  << EOF
CREATE DATABASE IF NOT EXISTS hina_db ;
SHOW DATABASES ;
CREATE USER "hina"@"wordpress.srcs_my_network" IDENTIFIED BY "$MYSQL_DB_PASS";
GRANT ALL PRIVILEGES ON hina_db.* TO "hina"@"wordpress.srcs_my_network" IDENTIFIED BY "$MYSQL_DB_PASS";
CREATE USER "hina"@"phpmyadmin.srcs_my_network" IDENTIFIED BY "$MYSQL_DB_PASS";
GRANT ALL PRIVILEGES ON hina_db.* TO "hina"@"phpmyadmin.srcs_my_network" IDENTIFIED BY "$MYSQL_DB_PASS";
FLUSH PRIVILEGES;
EOF
sleep 3
service mysql stop
exec mysqld
