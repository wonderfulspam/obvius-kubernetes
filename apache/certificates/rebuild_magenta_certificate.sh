#!/bin/bash

CERTNAME=magenta_multi_host

cd /etc/apache2/certificates/

echo "Generating configuration file"
cp magenta-template.conf ${CERTNAME}.conf

HOSTNAME_COUNT=1
for x in /etc/apache2/certificates/magenta_multi_host.d/*.conf; do
    for a in $(cat "$x"); do
	if [ "x${a}" != "x" ]; then
	    echo "DNS.${HOSTNAME_COUNT} = ${a}" >> ${CERTNAME}.conf
	    HOSTNAME_COUNT=$((HOSTNAME_COUNT+1))
	fi
    done
done

echo "Generating key and .csr"
openssl req -config ${CERTNAME}.conf -new -sha256 -newkey rsa:2048 -nodes -keyout ${CERTNAME}.key -days 3650 -out ${CERTNAME}.csr

echo "Generating and signing certificate"
openssl x509 -sha256 -req -in ${CERTNAME}.csr -CA magentaCA2.crt -CAkey magentaCA2.key -CAcreateserial -out ${CERTNAME}.crt -days 3650 -extfile ${CERTNAME}.conf -extensions v3_req

echo "Done"




