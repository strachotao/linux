#!/bin/bash
# generovani CSR zadosti; version 2022-10-24; strachotao
#  chrome 58+ vidi jako secured
#
#  site1 bude CN, site2+ bude SAN (alt.subject name)

EMAIL="name@domain.cz"
TLD="CZ"
COUNTRY="Czech Republic"
CITY="Brno"
OU="IT"
O="Company"

function getconfig {
cat <<-'CONFIG'
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
dir            = .                    # top dir
database       = $dir/index.txt        # index file.
new_certs_dir  = $dir/newcerts         # new certs dir
certificate    = $dir/CA.crt       # The CA cert
serial         = $dir/serial           # serial no file
private_key    = $dir/CA.key            # CA private key
RANDFILE       = $dir/.rand    # random number file
default_days   = 730                  # how long to certify for
default_crl_days= 30                   # how long before next CRL
#default_md     = sha512                   # md to use
default_md     = sha256                   # md to use
policy         = policy_any            # default policy
email_in_dn    = no                    # Don't add the email into cert DN
name_opt       = ca_default            # Subject name display option
cert_opt       = ca_default            # Certificate display option
copy_extensions = none                 # Don't copy extensions from request
distinguished_name = req_distinguished_name

[ req ]
default_bits            = 4096
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions = v3_ca

[ req_distinguished_name ]
countryName                    = Country Name (2 letter code)
countryName_default            = CZ
countryName_min                = 2
countryName_max                = 2
stateOrProvinceName            = State
stateOrProvinceName_default    = Czech Republic
localityName                   = Locality Name (eg, city)
localityName_default           = Brno
organizationalUnitName         = Organizational Unit Name (eg, section)
organizationalUnitName_default = Data Centers & Networks
commonName                     = Common Name (eg, YOUR name)
commonName_max                 = 64
emailAddress_max               = 40

[ policy_any ]
countryName            = supplied
stateOrProvinceName    = optional
organizationName       = optional
commonName             = supplied

[ v3_ca ]
 subjectKeyIdentifier=hash
 authorityKeyIdentifier=keyid:always,issuer:always
 basicConstraints = CA:true

[ req_attributes ]
 challengePassword              = A challenge password

[SAN]
 
CONFIG
}

if [[ $# -lt 1 ]]; then
	echo "Generuje CSR zadost a klic. site2+ budou vlozeny do 'X509v3 Subject Alternative Name'"
        echo "Usage: $0 {site1} [site2 site3 ... siteN]"
        echo "Usage: $0 mojedomena.cz"
        echo "Usage: $0 prvni.mojedomena.cz druhy.mojedomena.cz treti.mojedomena.cz"
        echo
        exit 1
fi
data="$(getconfig)"
counter=1
sites="subjectAltName="
for param in "$@"; do
	sites+="DNS:$param,"
	if [[ "$counter" -eq 1 ]]; then
		fsite="$param"
	fi
	counter=$((counter+1))
done
sites="${sites::-1}"
data+="$sites"
openssl req \
	-newkey rsa:4096 \
	-nodes \
	-keyout ${fsite}.key \
	-new \
	-out ${fsite}.csr \
	-subj "/emailAddress=${EMAIL}/C=${TLD}/ST=${COUNTRY}/L=${CITY}/O=${O}/OU=${OU}/CN=${fsite}" \
	-reqexts SAN \
	-extensions SAN \
	-config <( cat <<< "$data" ) \
	-sha256
echo
echo "openssl req -text -noout -verify -in ${fsite}.csr"
echo
cat ${fsite}.csr
