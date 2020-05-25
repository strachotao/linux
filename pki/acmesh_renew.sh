#!/bin/bash
# acmesh_renew; version 2020-05-26; strachotao
#  velmi jednoucelove pro RENEW lets encrypt certifikatu, na boxu kde mame iptables+nginx+acme.sh
#	

if [ $# -lt 1 ]; then
        echo "usage: $0 {domain1} [domain2] [domain...]"
        echo "example1: $0 domain.com"
        echo "example2: $0 domain.com domain.net"
	if [ -f /root/.acme.sh/acme.sh ]; then
		echo
		echo "seznam domen spravovanych acme:"
		/root/.acme.sh/acme.sh --list
	fi
        exit 1
fi

echo "[$(date)] start..."

for item in "$@"; do
        if [ ! -d "/root/.acme.sh/$item" ]; then
                echo "[$(date)] domena $item neni na tomto serveru nakonfigurovana"
                echo "spustte napr.:"
                echo " service iptables stop; service nginx stop"
                echo " ./acme.sh -d $item --issue --standalone --use-wget --insecure"
                echo " service iptables start; service nginx start"
        else
                domains+=" $item"
        fi
done

if [[ -z "${domains// }" ]]; then
        echo "[$(date)] nemame domenu ke zpracovani, konec"
        exit 1
fi

echo "[$(date)] zastavuji iptables a nginx"

service iptables stop
service nginx stop

cd /root/.acme.sh/
for domain in $domains; do
        echo "[$(date)] spoustim renew pro $domain"
        ./acme.sh -d $domain --renew --standalone --use-wget --insecure
        echo "[$(date)] renew $domain je hotovy"
done

echo "[$(date)] spoustim iptables a nginx"

service iptables restart
service nginx start

echo "[$(date)] konec"
