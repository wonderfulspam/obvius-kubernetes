FROM debian:stable-slim

RUN apt-get update && apt-get install apache2 -y

COPY ku_docker.conf /etc/apache2/sites-available/ku_docker.conf
COPY certificates/* /etc/apache2/certificates/

RUN a2enmod headers
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl
RUN a2ensite ku_docker


