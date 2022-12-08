#!/bin/bash

CERTS_PREFIX=$1
CLIENT_DOMAIN=gto


echo "Step1: Create CSR request for client"
echo "openssl req -out $CERTS_PREFIX-client.csr -newkey rsa:2048 -nodes -keyout $CERTS_PREFIX-client.key -subj "/CN=$CLIENT_DOMAIN.com/O=Global Travel Organization""
openssl req -out $CERTS_PREFIX-client.csr -newkey rsa:2048 -nodes -keyout $CERTS_PREFIX-client.key -subj "/CN=$CLIENT_DOMAIN.com/O=Global Travel Organization"

echo "Step3: Sign Client Certificate"
echo "openssl x509 -req -days 365 -CA ca-root.crt -CAkey ca-root.key -set_serial 1 -in $CERTS_PREFIX-client.csr -out $CERTS_PREFIX-client.crt"
openssl x509 -req -days 365 -CA ca-root.crt -CAkey ca-root.key -set_serial 1 -in $CERTS_PREFIX-client.csr -out $CERTS_PREFIX-client.crt



