#!/bin/bash
# extract-ssl-cert-from-pfx.sh; verze 2023-09-11; strachotao
#  wget https://raw.githubusercontent.com/strachotao/linux/master/pki/extract-ssl-cert-from-pfx.sh
#
#  nastaveni
#
#  v poli pfx je: ["soubor-certifikatu-a-klice.pfx"]="hesloklice"
#
#  generovani konfigurace pro vice souboru
#  for file in $(ls -1 *pfx); do echo "[\"$file\"]=\"hesloPlaceHolder\""; done



#Pre portal advisor.uniqa.cz
declare -A pfx=(
	["strachota.eu.pfx"]="heslo"
	["strachota.net.pfx"]="heslo"
	["nejakadomena.cz.pfx"]="heslo"
)
#  konec nastaveni


DELIMITER=$(printf '%46s\n' | tr ' ' =)
debug=true
srv="srv"
ansibleCmdFile="/tmp/ansibleCmd"
while [[ $# -gt 0 ]]; do
	param="$1"
	shift;
	case $param in
		-s)	srv="$1";shift;;
		-f)	intfile=true;intfilename="$1";shift;;
		-i)	inter=true;;
		-p)	debug=false;;
		-h)     haproxy=true;;
		*) echo "Spatny parametr!";;
    	esac
done

echo "pouziti: $0 [-p] [-i] [-f soubor]"
echo "    -p : provede zpracovani, bez tohoto parametru neudela nic, pouze zobrazi stav ('dry run')"
echo "    -s : nazev serveru, kt. bude zobrazovan pro ansible"
echo "    -i : do souboru certifikatu zapise i mezilehly certifikat (dafaultne pokud je v pfx), nebo ze souboru: -f soubor"
echo "    -h : provede zapsani klice a certifikatu do souboru server.pem - pouziti pro haproxy"
echo "    -f : soubor mezilehleho certifikatu"
echo
echo "priklad: $0 -p -i -f intCA.cer -s server1"
echo "         $0 -p -i"
echo "         $0 -p -i -f intCA.cer -h"
echo
echo
echo -e "$DELIMITER"

if [[ -n ${intmfil} && ! -f ${intmfil} ]]; then
	echo -e " $(tput setaf 1)Zdrojovy soubor intm. certifikatu ${intmfil} nelze precist!$(tput sgr0)\n${DELIMITER}"
	exit 1	
fi

if  [[ -f "$ansibleCmdFile" ]]; then
	rm -f $ansibleCmdFile
fi

for item in "${!pfx[@]}";
do
	filen="$item"

	echo "Start ${item}"
	if [ ! -f ${item} ]; then
		echo -e " $(tput setaf 1)Zdrojovy soubor ${item} nelze precist!$(tput sgr0)\n${DELIMITER}"
		continue
	fi
	openssl pkcs12 -in ${item} -noout -passin pass:"${pfx["$item"]}"
	if [ $? -eq 1 ]; then
		echo -e " $(tput setaf 1)${item} nemame spravne heslo!$(tput sgr0)\n${DELIMITER}"
		continue
	fi
	echo -e " $(tput setaf 2)${item} heslo OK$(tput sgr0)"
	openssl pkcs12 -in ${filen} -cacerts -nokeys -out /tmp/${item}.int.cer -passin pass:"${pfx["$item"]}"
	if [ -s /tmp/${item}.int.cer ]; then
		echo -e " $(tput setaf 2)${item} mezilehly certifikat je soucasti pfx!$(tput sgr0)"
	else
		echo -e " $(tput setaf 3)${item} mezilehly certifikat neni soucasti pfx!$(tput sgr0)"
	fi

	if [[ $intfile == true ]]; then
		if [ -s "$intfilename" ]; then
			echo -e " $(tput setaf 2)${item} mezilehly certifikat je v $intfilename $(tput sgr0)"
		else
			echo -e " $(tput setaf 1)${item} mezilehly certifikat $intfilename neni validni $(tput sgr0)"
		fi
	fi

	if [[ $debug == true ]]; then
		echo -e "$DELIMITER"
		continue
	fi
	echo "Exportuji..."

	item=$(sed 's/\.pfx//' <<< ${item})
	item=$(sed 's/\.p12//' <<< ${item})

	openssl pkcs12 -in ${filen} -clcerts -nokeys -out ${item}.cer -passin pass:"${pfx["$filen"]}"
	openssl pkcs12 -in ${filen} -cacerts -nokeys -out ${item}.int.cer -passin pass:"${pfx["$filen"]}"
	openssl pkcs12 -in ${filen} -nocerts -nodes  -out ${item}.enc.key -passin pass:"${pfx["$filen"]}"
	openssl rsa -in ${item}.enc.key -out ${item}.key
	rm -f ${item}.enc.key
	if [[ $inter == true ]]; then
		if [[ $intfile == true ]]; then
			echo "Zpracovavam mezilehly certifikat ze souboru..."
			if [ -s "$intfilename" ]; then
				cat  $intfilename >> ${item}.cer
			else
				echo -e " $(tput setaf 1)${item} soubor mezilehleho certifikatu nelze precist!$(tput sgr0)\n${DELIMITER}"
			fi
		else
			echo "Zpracovavam mezilehly certifikat z PFX..."
			cat ${item}.int.cer >> ${item}.cer
		fi	
	fi

	if [[ $haproxy == true ]]; then
		rm -f ${item}__server.pem
		cat ${item}.cer >> ${item}__server.pem
		cat ${item}.key >> ${item}__server.pem
		rm -f ${item}.int.cer ${item}.cer ${item}.key
       		echo
		echo "ansible -m copy -a \"src=${item}__server.pem dest=/etc/haproxy/ssl/${item}/server.pem backup=yes\" --become $srv"
		echo "ansible -m copy -a \"src=${item}__server.pem dest=/etc/haproxy/ssl/${item}/server.pem backup=yes\" --become $srv" >> $ansibleCmdFile
	else
       		echo
		echo "ansible -m copy -a \"src=${item}.cer dest=/etc/nginx/pki backup=yes\" --become $srv"
		echo "ansible -m copy -a \"src=${item}.cer dest=/etc/nginx/pki backup=yes\" --become $srv" >> $ansibleCmdFile
		echo "ansible -m copy -a \"src=${item}.key dest=/etc/nginx/pki backup=yes\" --become $srv"
		echo "ansible -m copy -a \"src=${item}.key dest=/etc/nginx/pki backup=yes\" --become $srv" >> $ansibleCmdFile
	fi	

	echo "https://www.ssllabs.com/ssltest/analyze.html?d=${item}&hideResults=on&latest"
	echo "https://www.ssllabs.com/ssltest/analyze.html?d=${item}&hideResults=on&latest" >> $ansibleCmdFile
	#echo
	#echo "apache:"
	#echo "ansible -m copy -a \"src=${item}.cer dest=/etc/pki/tls/certs backup=yes\" --become SERVER"
	#echo "ansible -m copy -a \"src=${item}.key dest=/etc/pki/tls/private backup=yes\" --become SERVER"
	#echo "ansible -m service -a \"name=httpd state=restarted\" --become SERVER"
	#echo
	#echo "SSLCertificateFile /etc/pki/tls/certs/${item}.cer"
	#echo "SSLCertificateKeyFile /etc/pki/tls/private/${item}.key"
	#echo "SSLCACertificateFile /etc/pki/tls/certs/digicert-thawte-int.cer"
	#echo
	#echo "ansible -m service -a \"name=nginx state=restarted\" --become SRV"
	#echo
	#echo "ssl_certificate /etc/nginx/pki/${item}.cer;"
	#echo "ssl_certificate_key /etc/nginx/pki/${item}.key;"
	#echo
	echo -e "Hotovo!\n${DELIMITER}"
done
echo "Ansible commandy jsou v $ansibleCmdFile"
