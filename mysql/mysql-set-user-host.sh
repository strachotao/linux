#!/bin/bash
# mysql-user-set-host.sh; version 2018-02-10; strachotao
#
#  nastavi host na existujicim uzivateli v mysql databazi
#  neni osetreno pokud existuje jeden uzivatel s vice hosty
#
#  pouziti pro docasne znemozneni uzivateli se prihlasit...
#
#  heslo se grepne ze souboru /root/.mytop
#
#  v crontabu se musi escapovat znak procenta, napr.:
#
#  03 01 10 02 * /root/mysql-user-set-host.sh uzivatel \%

if [[ $# -lt 2 ]]; then
        echo "Usage: $0 {user} {host}"
        exit 1
fi

USER="$1"
HOST="$2"

mysql -uroot -p$(grep pass /root/.mytop|cut -d" " -f3) -f << EOF
UPDATE mysql.user SET host = '${HOST}' WHERE user = '${USER}';
FLUSH PRIVILEGES;
EOF
