#!/bin/bash
# visual-ping; version 2024-01-04; strachotao

function Get-Timestamp {
    date +"%T"
}

if [[ "$1" && "$2" ]]; then
    target=$1
    waitUntilNextCycle=$2
    echo "given target is $target"
    echo "given period is ${waitUntilNextCycle}s"
else
    target="seznam.cz"
    waitUntilNextCycle=1
    echo "no given target, using default 'seznam.cz 1'"
fi

while true; do
    sleep $waitUntilNextCycle
    if res=$(ping -c 1 "$target" 2>/dev/null); then
        data=$(echo "$res"|grep '^64\ bytes'|cut -d ' ' -f 8)
        echo -n "[$(Get-Timestamp) OK ${data}]"|awk '{printf "\033[48;5;22m\033[38;5;15m%s\033[0m", $0}' 
    else
        echo -n "[$(Get-Timestamp) KO]"| awk '{printf "\033[48;5;52m\033[38;5;15m%s\033[0m", $0}'
    fi
done
