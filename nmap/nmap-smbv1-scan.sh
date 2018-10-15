#!/bin/bash
# nmap-smbv1-scan; version 2017-05-16; strachotao
# nmap 7.4+ required

SCRIPT_SOURCE="https://raw.githubusercontent.com/cldrn/nmap-nse-scripts/master/scripts/smb-vuln-ms17-010.nse"
WORKING_DIR="/opt/nmap-scan/"
BINARIES="nmap wget date basename mkdir"

function usage() {
cat << HELP
$0 [-c] [-d] [-s] -l <log file> -t <target1>,[<target2>,<target2>,<...>,<targetN>]

-c, --check     nepovinny; validace cile(u) pomoci ipcalc; nepouzivat v pripade hostname
-d, --download  nepovinny; stahnout znovu (prepsat) zdrojovy nmap skript
-l, --log       povinny; log soubor, k nazvu bude pridan prefix CDATE
-t, --target    povinny; IP nebo subnet, oddelovac je carka
-s, --dry-run   nepovinny; pouze a jen vypise, kt. co by udelal

priklady:
$0 -l \"Synology NAS\" -t 10.189.0.77
$0 -c -l ClientVLAN -t 192.168.0.0/24
$0 -d -l ALL -t 192.168.0.0/24,192.168.1.0/24

pouziti z cronu:
00 09 * * * /path/to/${0/.\//} -l ClientVLAN -t 192.168.0.0/24

HELP
        exit 1
}

function error() {
        echo -e "$(date +%F\ %T) ERROR: $@" >&2
        exit 1
}

function checkBin() {
        which "$@" >& /dev/null || \
                error "Nenalezena potrebna binarka: $@"
}

if [ $# -lt 3 ]; then
        usage
fi

for binary in $BINARIES; do
        checkBin "$binary"
done

CDATE=$(/bin/date '+%Y-%m-%d__%H-%M')
SCRIPT="${WORKING_DIR}$(/bin/basename $SCRIPT_SOURCE)"
DOWNLOAD=0
VALIDATE_TARGET=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
        param="$1"
        shift;
                case $param in
                        -l|--log)
                                LOG=$1
                                shift
                                ;;
                        -t|--target)
                                IFS=',' read -r -a TARGET <<< "$1"
                                shift
                                ;;
                        -d|--download)
                                DOWNLOAD=1
                                ;;
                        -c|--check)
                                VALIDATE_TARGET=1
                                ;;
                        -s|--dry-run)
                                DRY_RUN=1
                                ;;
                        *)
                                echo "Spatny parametr!"
                                usage
                                ;;
                esac
done

if [ ! -d ${WORKING_DIR} ]; then
        if [ ${DRY_RUN} -eq 1 ]; then
                echo "mkdir ${WORKING_DIR}"
        else
                mkdir ${WORKING_DIR}
        fi
fi

if [ ! -f ${SCRIPT} ] || [ ${DOWNLOAD} -eq 1 ]; then
        if [ ${DRY_RUN} -eq 1 ]; then
                echo "wget -O ${SCRIPT} ${SCRIPT_SOURCE}"
        else
                wget -O "${SCRIPT}" "${SCRIPT_SOURCE}"
        fi
fi

if [[ ${#TARGET[@]} -eq 0 ]]; then
        error "Neni zadana zadna IP nebo subnet"
else
        for target in ${TARGET[@]}; do
                if [ ${VALIDATE_TARGET} -eq 1 ]; then
                        which ipcalc >& /dev/null || \
                                error "Nenalezena binarka ipcalc, vynechte -c parametr"
                        ipcalc -s -c $target || \
                                error "Cil neni validni IP/subnet: $target"
                fi
                TARGETS+="$target "
        done
fi

if [ ${DRY_RUN} -eq 1 ]; then
        echo "nmap -sC -Pn -p445 --open --max-hostgroup 3 --script ${SCRIPT} ${TARGETS} >> ${CDATE}__${LOG}"
        exit 0
fi

nmap -sC -Pn -p445 --open --max-hostgroup 3 --script ${SCRIPT} ${TARGETS} >> "${CDATE}__${LOG}"
