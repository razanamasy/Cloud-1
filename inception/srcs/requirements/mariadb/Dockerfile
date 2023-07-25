FROM debian:buster
COPY conf/start.sh start.sh
RUN apt-get update
RUN yes | apt-get upgrade
RUN yes | apt-get install mariadb-server mariadb-client
RUN rm /etc/mysql/mariadb.conf.d/50-server.cnf
COPY /conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
EXPOSE 3306
RUN chmod 777 start.sh
RUN mkdir -p /var/lib/mysql
RUN	chown -R root /var/lib/mysql
RUN	chmod 777 /var/lib/mysql
CMD ["./start.sh"]
