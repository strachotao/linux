#!/bin/bash
#check tcp22; version 2020-07-08; strachotao
#
#sberac dat, volani z cronu:
# 04,09,14,19,24,29,34,39,44,49,54,59 * * * * /etc/munin/ssh_is_reachable.sh

serverExclude=("srv04" "srv05")
serverListFile="/etc/munin/servers.txt"
sshLog="/etc/munin/ssh_is_reachable_data"

if [ ! -f $serverListFile ]; then
	echo "File $serverListFile not found!"
	exit 1
fi

for server in $(grep -vi name ${serverListFile}); do
	if [[ ! " ${serverExclude[@]} " =~ " ${server} " ]]; then
		nc -z -w2 ${server} 22 > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			# dostupne servery
			outData+="${server};0"
		else
			# nedostupne servery
			outData+="${server};10"
		fi
	else
		# excludovane servery
		outData+="${server};5"
	fi
	outData+=$'\n'
done

echo "$outData" > $sshLog
