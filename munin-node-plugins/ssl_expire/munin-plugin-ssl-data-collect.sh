#!/bin/bash
# ssl-sites-watchdog; verze 2018-11-12; strachotao
#
#  pridavani/ubirani novych url se resi pres ansible,
#   rucne nesahat

SSL_PLUGINS_SOURCE="/etc/munin/plugins/ssl_*"
DATA_DIR="/etc/munin/plugin-ssl-data-collect/data"
DAYS_ON_ERROR=7

function usage() {
cat << HELP
$0 [-d <domena>] [-p <port>] | [-h]
-d, --debug     nepovinny; zobrazi jen vystup z jedne domeny
-p, --port      nepovinny; pokud neni definovano, pouzije se 443
-h, --help      nepovinny; vypise toto info

nacte z /etc/munin/plugins/ssl_* seznam URL, na kt.
se pripoji a vypise vystup do .data/${SITE}, tento obsah
si pak ctou pluginy /etc/munin/plugins/ssl_site_port_...

pokud nejde certifikat nacist, nastavi se hodnota expirace
na DAYS_ON_ERROR, coz bude v muninu vypadat jako critical

priklady:
$0
$0 -d www.seznam.cz
$0 -d api.strachota.net -p 8443

pouziti z cronu:
00 09 * * * ${0}
HELP
        exit 1
}

DEBUG=0
DEBUG_PORT=443

while [[ $# -gt 0 ]]; do
        param="$1"
        shift;
                case $param in
                        -d|--debug)
                                DEBUG=1
                                DEBUG_DOMAIN=$1
                                shift
                                ;;
                        -p|--port)
                                DEBUG_PORT=$1
                                shift
                                ;;
                        -h|--help)
                                usage
                                shift
                                ;;
                        *)
                                echo "Spatny parametr!"
                                usage
                                ;;
                esac
done

if [ ${DEBUG} -eq 1 ]; then
		echo "start: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "debug mod: ${DEBUG_DOMAIN}:${DEBUG_PORT}"
        echo "test portu pomoci nc:  nc -z -v -w5 ${DEBUG_DOMAIN} ${DEBUG_PORT}"
        nc -z -v -w5 ${DEBUG_DOMAIN} ${DEBUG_PORT} || exit 1
        echo "nacitam certifikat pomoci openssl:"
        echo | openssl s_client -servername $DEBUG_DOMAIN -connect ${DEBUG_DOMAIN}:${DEBUG_PORT} 2>/dev/null | openssl x509 -text
        exit 0
fi

while read SITE PORT TYPE; do
    [[ "${SITE:0:1}" =~ ^[a-z,A-Z,0-9] ]] && {
        days=$DAYS_ON_ERROR
        cat /dev/null > ${DATA_DIR}/${SITE}
        cert=$(echo "" | openssl s_client -CApath /etc/ssl/certs -servername "${SITE}" -connect "${SITE}:${PORT}" 2>/dev/null);
        if [[ "${cert}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
                days=$(echo "${cert}" | openssl x509 -noout -enddate | awk -F= 'BEGIN { split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month, " "); for (i=1; i<=12; i++) mdigit[month[i]] = i; } /notAfter/ { split($0,a,"="); split(a[2],b," "); split(b[3],time,":"); datetime=b[4] " " mdigit[b[1]] " " b[2] " " time[1] " " time[2] " " time[3]; days=(mktime(datetime)-systime())/86400; print days; }')
                echo "${days}" >> ${DATA_DIR}/${SITE}
        else
                echo "${days}" >> ${DATA_DIR}/${SITE}
        fi

    }
done <<< "$(ls -1 ${SSL_PLUGINS_SOURCE} | cut -d'_' -f2,3,4 | sed 's/_/\ /g')"
