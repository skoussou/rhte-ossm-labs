#!/bin/bash

SM_CP_NS_ORIGINAL=$1
DOMAIN_NAME=$2
PARTICIPANTID=$3

PREFIX=gto-user-$PARTICIPANTID
SM_CP_NS=user-$PARTICIPANTID-$SM_CP_NS_ORIGINAL

echo '---------------------------------------------------------------------------'
echo 'ServiceMesh Control Plane Namespace        : '$SM_CP_NS
echo 'CLUSTER DOMAIN Name                        : '$DOMAIN_NAME
echo 'PREFIX                                     : '$PREFIX
echo 'Remote SMCP Route Name (when NO DNS)       : 'https://$PREFIX.$DOMAIN_NAME
echo '---------------------------------------------------------------------------'

sleep 10
echo
echo "================================================================================="
echo "Create CA ROOT and Gateway Self-Signed Certificates for ($PREFIX)"
echo "================================================================================="
echo
echo "Create CA Root Keys (Only once for client and service)"
echo "-------------------------------------------------------"
echo "openssl req -x509 -newkey rsa:4096 -days 365 -nodes -keyout ca-root.key -out ca-root.crt -subj "/C=UK/ST=London/L=London/OU=stelios/CN=redhat.com/emailAddress=stelios@redhat.com""
openssl req -x509 -newkey rsa:4096 -days 365 -nodes -keyout ca-root.key -out ca-root.crt -subj "/C=UK/ST=London/L=London/OU=stelios/CN=redhat.com/emailAddress=stelios@redhat.com"
echo
sleep 5
echo
echo "[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
prompt = no
[ dn ]
C = UK
O = RH
CN = $PREFIX.$DOMAIN_NAME
ST = Baker Street
L = London
OU=RedHat
[ req_distinguished_name ]
countryName = UK
stateOrProvinceName = London
localityName = London
organizationName = RedHat
commonName = $PREFIX.$DOMAIN_NAME
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $PREFIX.$DOMAIN_NAME"

echo "[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
prompt = no
[ dn ]
C = UK
O = RH
CN = $PREFIX.$DOMAIN_NAME
ST = Baker Street
L = London
OU=RedHat
[ req_distinguished_name ]
countryName = UK
stateOrProvinceName = London
localityName = London
organizationName = RedHat
commonName = $PREFIX.$DOMAIN_NAME
[ req_ext ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $PREFIX.$DOMAIN_NAME" > $PREFIX.conf

sleep 5
echo
echo
echo "Create Certificate Signing Request, TLS Certificate for hosted service for the app (self-signed)"
echo "---------------------------------------------------------------------------------"
echo
echo "create-app-csr-certs-keys.sh $PREFIX.conf $PREFIX"
./create-app-csr-certs-keys.sh $PREFIX.conf $PREFIX
sleep 5
echo

echo "Create OCP secret to store the certificate in $SM_CP_NS"
echo "-----------------------------------------------------------------------------"
echo "Removing first secret/$PREFIX-secret if already in the namespace ..."
sleep 1
oc -n $SM_CP_NS delete secret/$PREFIX-secret

echo "oc create secret generic $PREFIX-secret
        --from-file=tls.key=$PREFIX-app.key \
        --from-file=tls.crt=$PREFIX-app.crt \
        --from-file=ca.crt=ca-root.crt \
        -n $SM_CP_NS"

oc create secret generic $PREFIX-secret \
        --from-file=tls.key=$PREFIX-app.key \
        --from-file=tls.crt=$PREFIX-app.crt \
        --from-file=ca.crt=ca-root.crt \
        -n $SM_CP_NS
echo
echo
sleep 5
echo
echo

echo "================================================================================="
echo "Apply initial Istio Configs to Route external Traffic via Service Mesh Ingress"
echo
echo "Service Mesh Ingress Gateway Route"
echo "Ingress Route [$PREFIX.$DOMAIN_NAME]"
echo "================================================================================="
echo
sleep 3
echo
echo "Create PASSTHROUGH Route Resource [$PREFIX]"
echo "---------------------------------------------"
echo "kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: $PREFIX
  namespace: $SM_CP_NS
spec:
  host: $PREFIX.$DOMAIN_NAME
  to:
    kind: Service
    name: $PREFIX-ingressgateway
    weight: 100
  port:
    targetPort: https
  tls:
    termination: passthrough
  wildcardPolicy: None"

echo "kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: $PREFIX
  namespace: $SM_CP_NS
spec:
  host: $PREFIX.$DOMAIN_NAME
  to:
    kind: Service
    name: $PREFIX-ingressgateway
    weight: 100
  port:
    targetPort: https
  tls:
    termination: passthrough
  wildcardPolicy: None" | oc apply -n $SM_CP_NS -f -
echo
sleep 3

echo
echo
echo "Create HTTPS Gateway Resource "
echo "--------------------------------"
echo
echo "kind: Gateway
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: travel-api-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - hosts:
        - $PREFIX.$DOMAIN_NAME
      port:
        name: https
        number: 443
        protocol: HTTPS
      tls:
        credentialName: $PREFIX-secret
        mode: MUTUAL
  selector:
    app: $PREFIX-ingressgateway"

echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: travel-api-gateway
  namespace: $SM_CP_NS
spec:
  servers:
    - hosts:
        - $PREFIX.$DOMAIN_NAME
      port:
        name: https
        number: 443
        protocol: HTTPS
      tls:
        credentialName: $PREFIX-secret
        mode: MUTUAL
  selector:
    app: $PREFIX-ingressgateway" | oc apply -n $SM_CP_NS -f -
#   istio: ingressgateway

echo
echo
sleep 5
echo "===================================================================================="
echo "Create client certificates based on the same CA Root for mTLS communications towards"
echo "Ingress Route [$PREFIX.$DOMAIN_NAME]"
echo "===================================================================================="
echo
echo create-client-certs-keys.sh curl
./create-client-certs-keys.sh curl

echo
sleep 5
echo
echo "External URL for Global Organization(GTO) access to Travel Domain Services APIs over mutual HTTPS"
echo "-------------------------------------------------------------------------------------------------"
echo
echo "https://$(oc get route $PREFIX -o jsonpath='{.spec.host}' -n $SM_CP_NS)"



