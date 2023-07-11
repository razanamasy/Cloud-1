FROM debian:buster

RUN apt-get update
RUN yes | apt-get upgrade
RUN yes | apt-get install nginx openssl
RUN	mkdir -p /etc/nginx/ssl
RUN	mkdir -p /var/www/phpmyadmin
RUN openssl req -sha256 -nodes -newkey rsa:4096 -x509 -days 365 -nodes -keyout /etc/nginx/ssl/localhost.key -out /etc/nginx/ssl/localhost.pem -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=localhost/CN=localhost"
COPY /conf/default /etc/nginx/sites-available/default
EXPOSE 443
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
