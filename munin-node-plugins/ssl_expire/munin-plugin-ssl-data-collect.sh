#!/bin/bash
# ssl-sites-watchdog; verze 2018-07-16; strachotao
#
#  nacte z /etc/munin/plugins/ssl_* seznam URL, na kt.
#  se pripoji a vypise vystup do .data/${SITE}, tento obsah
#  si pak ctou pluginy /etc/munin/plugins/ssl_site_port_...
#
#  pridavani/ubirani/deploy novych url se resi pres ansible,
#   rucne nesahat
#
#  pokud nejde certifikat nacist, nastavi se hodnota expirace
#  na 7, coz bude v muninu vypadat jako critical

SSL_PLUGINS_SOURCE="/etc/munin/plugins/ssl_*"
DATA_DIR="/etc/munin/plugin-ssl-data-collect/data"

while read SITE PORT TYPE; do
    [[ "${SITE:0:1}" =~ ^[a-z,A-Z,0-9] ]] && {
        days=7
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
