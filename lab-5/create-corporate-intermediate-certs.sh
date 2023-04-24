#!/bin/bash

BASE_DIR=$1

cd $BASE_DIR/certs-resources
#mkdir -p certs
#mkdir -p crl
#mkdir -p csr
#mkdir -p newcerts
#mkdir -p private
#mkdir -p intermediate/certs
#mkdir -p intermediate/crl
#mkdir -p intermediate/csr
#mkdir -p intermediate/newcerts
#mkdir -p intermediate/private

echo
echo
echo "=========================================================================================================="
echo " Creating openssl.cnf for ROOT CA (<BASE_DIR>/certs-resources/openssl.cnf)                   "
echo "=========================================================================================================="
echo

echo '# OpenSSL root CA configuration file.
# Copy to `/root/ca/openssl.cnf`.

[ ca ]
# `man ca`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
#dir               = /root/ca
dir               = <BASE_DIR>/certs-resources
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of `man ca`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = GB
stateOrProvinceName_default     = England
localityName_default            = London
0.organizationName_default      = Red Hat
organizationalUnitName_default  =
emailAddress_default            =

[ v3_ca ]
# Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning' > openssl.cnf

echo
echo "=========================================================================================================="
echo " Creating openssl.cnf for INTERMEDIATE CA (<BASE_DIR>/certs-resources/intermediate/openssl.cnf)           "
echo "=========================================================================================================="
echo


cd intermediate

echo '# OpenSSL root CA configuration file.
# Copy to `/root/ca/openssl.cnf`.

[ ca ]
# `man ca`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
#dir               = /root/ca
dir               = <BASE_DIR>/certs-resources/intermediate
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/private/intermediate.key.pem
certificate       = $dir/certs/intermediate.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/intermediate.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of `man ca`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = GB
stateOrProvinceName_default     = England
localityName_default            = London
0.organizationName_default      = Red Hat
organizationalUnitName_default  =
emailAddress_default            =

[ v3_ca ]
# Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
# Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (`man ocsp`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning' > openssl.cnf

cd ..

#echo "find . -type f -name *.cnf |xargs sed -i 's@<BASE_DIR>@$BASE_DIR@g'"
find . -type f -name "*.cnf" |xargs sed -i "s@<BASE_DIR>@$BASE_DIR@g"


while true; do

read -p "Are openssl.conf files correctly created? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
echo
echo
echo "================================================================"
echo "Create Root key"
echo "================================================================"
openssl genrsa -aes256 -passout pass:foobar -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

sleep 5

echo
echo
echo
echo
echo "================================================================"
echo "Create Root key"
echo "================================================================"
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -passin pass:foobar \
      -subj "/C=GB/ST=England/L=London/O=Travel Agency Ltd/OU=Certificate Authority/CN=www.travelagency.com/emailAddress=ca@www.travelagency.com" \
      -out certs/ca.cert.pem


sleep 5

echo
echo
echo
echo
echo "================================================================"
echo "Verify the root certificate"
echo "================================================================"
openssl x509 -noout -text -in certs/ca.cert.pem

echo "----------------------------------------------------------------"
sleep 10

echo
echo
echo
echo
echo "================================================================"
echo "Create the intermediate pair"
echo "================================================================"
echo
echo "1-Prepare Directories"
echo "-------------------------------------"
cd ./intermediate
chmod 700 private
touch index.txt
echo 1000 > serial

echo
echo "2-Create the intermediate CA key"
echo "-------------------------------------"
echo

cd ../

openssl genrsa -passout pass:foobar -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

sleep 5

echo
echo "3-Create the intermediate CA certificate"
echo "------------------------------------------------"
sleep 3

echo
echo "3a-Use the intermediate key to create a certificate signing request (CSR)"
echo "------------------------------------------------"
echo
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -passin pass:foobar \
      -subj "/C=GB/ST=England/L=London/O=Travel Agency Ltd/OU=Intermediate Certificate Authority/CN=www.travelagency.com/emailAddress=ca@www.travelagency.com" \
      -out intermediate/csr/intermediate.csr.pem

sleep 5

echo
echo "3b-Create an intermediate certificate"
echo "------------------------------------------------"
echo
openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -passin pass:foobar \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

sleep 5


echo
echo
echo "================================================================"
echo "4-Verifications"
echo "================================================================"
echo

sleep 5

echo
echo "4a-index.txt"
echo "------------------------------------------------"
echo
cat index.txt
sleep 6

echo
echo "Verify the intermediate certificate"
echo "------------------------------------------------"
echo

openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem

while true; do

read -p "intermediate certificate ok? (yes/no) " yn
case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
echo

openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem

echo
echo

while true; do

read -p "intermediate certificate vs ROOT cert ok? (yes/no) " yn
case $yn in
	yes ) echo ok, we will proceed;
		break;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac
done

echo
echo
echo "================================================================"
echo "5-Create the certificate chain file"
echo "================================================================"
echo
sleep 2
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem