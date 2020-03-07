#!/bin/bash
#
# extract-ssl-cert-from-pfx.sh; verze 2018-10-01; strachotao 
#
#  v poli pfx je: ["soubor.pfx"]="hesloklice"

declare -A pfx=(
        ["strachota.net.pfx"]="heslo"
        ["example.com.pfx"]="heslo"
)

DELIMITER=$(printf '%46s\n' | tr ' ' =)

for item in "${!pfx[@]}";
do
        echo "Start ${item}"
        if [ ! -f ${item} ]; then
                echo -e "Zdrojovy soubor ${item} nelze precist!\n${DELIMITER}"
                continue
        fi
        openssl pkcs12 -in ${item} -noout -passin pass:"${pfx["$item"]}"
        if [ $? -eq 1 ]; then
                echo -e "K ${item} nemame spravne heslo!\n${DELIMITER}"
                continue
        fi

        echo "Exportuji..."

        openssl pkcs12 -in ${item} -clcerts -nokeys -out ${item}.cer -passin pass:"${pfx["$item"]}"
        openssl pkcs12 -in ${item} -nocerts -nodes  -out ${item}.enc.key -passin pass:"${pfx["$item"]}"
        openssl rsa -in ${item}.enc.key -out ${item}.key
        rm -f ${item}.enc.key

        read -p "Zkopirovat klice ${item} do /etc/pki/tls/certs|private...? (y/n)" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]
        then

                if [[ -f /etc/pki/tls/certs/${item}.cer ]]; then
                        cp /etc/pki/tls/certs/${item}.cer /etc/pki/tls/certs/${item}.cer.bck$(date +%Y%m%d)
                fi

                if [[ -f /etc/pki/tls/private/${item}.key ]]; then
                        cp /etc/pki/tls/private/${item}.key /etc/pki/tls/private/${item}.key.bck$(date +%Y%m%d)
                fi

                cp -v ${item}.cer /etc/pki/tls/certs/${item}.cer
                cp -v ${item}.key /etc/pki/tls/private/${item}.key

        fi
        echo
        echo "konfigurace pro apache:"
        echo "SSLCertificateFile /etc/pki/tls/certs/${item}.cer"
        echo "SSLCertificateKeyFile /etc/pki/tls/private/${item}.key"
        echo "SSLCACertificateFile /etc/pki/tls/certs/digicert-thawte-int.cer"
        echo
        echo "konfigurace nginx:"
        echo "ssl_certificate /etc/nginx/pki/${item}.cer;"
        echo "ssl_certificate_key /etc/nginx/pki/${item}.key;"
        echo
        echo -e "Hotovo!\n${DELIMITER}"

done
