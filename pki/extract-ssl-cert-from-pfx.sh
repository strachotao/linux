#!/bin/bash
#
# extract-ssl-cert-from-pfx.sh; verze 2020-06-04; strachotao 
#
#  v poli pfx je: ["soubor-certifikatu-a-klice.pfx"]="hesloklice"

declare -A pfx=(
	["strachota.eu.pfx"]="heslo"
	["strachota.net.pfx"]="heslo"
)

DELIMITER=$(printf '%46s\n' | tr ' ' =)
debug=true

while [[ $# -gt 0 ]]; do
	param="$1"
	shift;
	case $param in
		-f|--intmfil)	intmfil="$1";shift;;
		-p|--process)	debug=false;;
		*) echo "Spatny parametr!";;
    	esac
done

echo "pouziti: $0 [-p] [--process] [-f] [--intmfil]"
echo "    -p provede zpracovani, bez tohoto parametru neudela nic, pouze zobrazi stav ('dry run')"
echo "    -f soubor intermediate certfikatu, jehoz obsah bude pridan do souboru certifikatu (vyhodne u nginx)"
echo -e "$DELIMITER"

if [[ -n ${intmfil} && ! -f ${intmfil} ]]; then
	echo -e "$(tput setaf 1)Zdrojovy soubor intm. certifikatu ${intmfil} nelze precist!$(tput sgr0)\n${DELIMITER}"
	exit 1	
fi

for item in "${!pfx[@]}";
do
	echo "Start ${item}"
	if [ ! -f ${item} ]; then
		echo -e "$(tput setaf 1)Zdrojovy soubor ${item} nelze precist!$(tput sgr0)\n${DELIMITER}"
		continue
	fi
	openssl pkcs12 -in ${item} -noout -passin pass:"${pfx["$item"]}"
	if [ $? -eq 1 ]; then
		echo -e "$(tput setaf 1)${item} nemame spravne heslo!$(tput sgr0)\n${DELIMITER}"
		continue
	fi
	echo -e "$(tput setaf 2)${item} heslo OK$(tput sgr0)"
	if [[ $debug == true ]]; then
		echo -e "$DELIMITER"
		continue
	fi
	echo "Exportuji..."
	filen="$item"
	item=$(sed 's/\.pfx//' <<< ${item})
	openssl pkcs12 -in ${filen} -clcerts -nokeys -out ${item}.cer -passin pass:"${pfx["$filen"]}"
	openssl pkcs12 -in ${filen} -nocerts -nodes  -out ${item}.enc.key -passin pass:"${pfx["$filen"]}"
	openssl rsa -in ${item}.enc.key -out ${item}.key
	rm -f ${item}.enc.key
	if [[ -n ${intmfil} ]]; then
		cat ${intmfil} >> ${item}.cer
	fi
	read -p "Zkopirovat klice ${item} do /etc/pki/tls/certs|private...? (y/n)" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
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
	echo "apache:"
	echo "ansible -m copy -a \"src=${item}.cer dest=/etc/pki/tls/certs backup=yes\" --become SERVER"
	echo "ansible -m copy -a \"src=${item}.key dest=/etc/pki/tls/private backup=yes\" --become SERVER"
	echo "ansible -m service -a \"name=httpd state=restarted\" --become SERVER"
	echo
	echo "SSLCertificateFile /etc/pki/tls/certs/${item}.cer"
	echo "SSLCertificateKeyFile /etc/pki/tls/private/${item}.key"
	echo "SSLCACertificateFile /etc/pki/tls/certs/digicert-thawte-int.cer"
	echo
	echo
	echo "nginx:"
	echo "ansible -m copy -a \"src=${item}.cer dest=/etc/nginx/pki backup=yes\" --become SERVER"
	echo "ansible -m copy -a \"src=${item}.key dest=/etc/nginx/pki backup=yes\" --become SERVER"
	echo "ansible -m service -a \"name=nginx state=restarted\" --become SERVER"
	echo
	echo "ssl_certificate /etc/nginx/pki/${item}.cer;"
	echo "ssl_certificate_key /etc/nginx/pki/${item}.key;"
	echo
	echo -e "Hotovo!\n${DELIMITER}"
done
