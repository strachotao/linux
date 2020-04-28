#!/bin/bash
# p; ver 2020-04-28; strachotao

# jednoduchy test, zda se lze dostat do internetu
#  obvykle umisteni /bin/p

# reprezentuje internet...
internet="seznam.cz"

# reprezentuje gw/router/dns...
gw="core"

red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

date
ping -c2 $internet
if [ $? -eq 0 ]; then
	echo "--- Vysledek ---"
	echo -e "${green}Internet je dostupny${reset}"
	exit 0
else
	ping -c2 $gw
	echo "--- Vysledek ---"
	if [ $? -eq 0 ]; then
		echo -e "${green}core je dostupny${reset}"
	else
		echo -e "${red}core je nedostupny${reset}"
	fi
	echo -e "${red}Internet je nedostupny${reset}"
	exit 1
fi
