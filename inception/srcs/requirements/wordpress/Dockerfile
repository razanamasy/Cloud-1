FROM debian:buster
COPY conf/start.sh /start.sh


RUN apt-get update
RUN yes | apt-get upgrade
RUN yes | apt-get install mariadb-client
RUN yes | apt-get install php php7.3-fpm php-mysqli
RUN yes | apt-get install curl
RUN yes | curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN mv wp-cli.phar /usr/local/bin/wp
RUN chmod +x  /usr/local/bin/wp

RUN rm /etc/php/7.3/fpm/pool.d/www.conf
COPY conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf

RUN rm /etc/php/7.3/fpm/php-fpm.conf
COPY conf/www.conf /etc/php/7.3/fpm/php-fpm.conf

RUN mkdir -p /var/www/html
EXPOSE 9000
CMD ["bash", "start.sh"]
