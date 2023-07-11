FROM phpmyadmin/phpmyadmin 
COPY conf/start.sh start.sh
RUN chmod 777 start.sh
RUN apt-get update
RUN yes | apt-get upgrade
EXPOSE 80
CMD ["./start.sh"]
































