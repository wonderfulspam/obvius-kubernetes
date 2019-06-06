FROM httpd:2.4
COPY ku_docker.conf /usr/local/apache2/conf/ku_docker.conf
COPY certificates/* /etc/apache2/certificates/

RUN a2enmod headers
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl
RUN a2ensite ku_docker


