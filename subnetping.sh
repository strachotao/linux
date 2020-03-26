#!/bin/bash
# subnet ping; verze 2020-03-15; osx
#   rhel7+

tmp0="/tmp/myping"
vendorlist="/tmp/oui.txt"
IP_RAW_DATA=$(ip -o -f inet a s|grep -v "127.0.0.1")
IP_ADDR=$(awk '{print $4}' <<< "$IP_RAW_DATA" | cut -d/ -f1)
IP_CIDR=$(awk '{print $4}' <<< "$IP_RAW_DATA" | cut -d/ -f2)
IP_BRD=$(awk '{print $6}' <<< "$IP_RAW_DATA")

function core_determine() {
	case $1 in
		64) echo -n "linux/unix" ;;
		128) echo -n "windows" ;;
		254) echo -n "solaris/aix/cisco" ;;
		255) echo -n "linux/unix" ;;
		*) echo -n "ttl=$1 neznamy" ;;
	esac	
}

function network_address_to_ips() {
# source: https://stackoverflow.com/questions/16986879/bash-script-to-list-all-ips-in-prefix/
	ips=()
	network=(${1//\// })
	iparr=(${network[0]//./ })
	if [[ ${network[1]} =~ '.' ]]; then
		netmaskarr=(${network[1]//./ })
	else
		if [[ $((8-${network[1]})) -gt 0 ]]; then
			netmaskarr=($((256-2**(8-${network[1]}))) 0 0 0)
		elif  [[ $((16-${network[1]})) -gt 0 ]]; then
			netmaskarr=(255 $((256-2**(16-${network[1]}))) 0 0)
		elif  [[ $((24-${network[1]})) -gt 0 ]]; then
			netmaskarr=(255 255 $((256-2**(24-${network[1]}))) 0)
		elif [[ $((32-${network[1]})) -gt 0 ]]; then 
			netmaskarr=(255 255 255 $((256-2**(32-${network[1]}))))
		fi
  	fi
  	[[ ${netmaskarr[2]} == 255 ]] && netmaskarr[1]=255
  	[[ ${netmaskarr[1]} == 255 ]] && netmaskarr[0]=255
  	for i in $(seq 0 $((255-${netmaskarr[0]}))); do
		for j in $(seq 0 $((255-${netmaskarr[1]}))); do
      		for k in $(seq 0 $((255-${netmaskarr[2]}))); do
        		for l in $(seq 1 $((255-${netmaskarr[3]}))); do
          			ips+=( $(( $i+$(( ${iparr[0]}  & ${netmaskarr[0]})) ))"."$(( $j+$(( ${iparr[1]} & ${netmaskarr[1]})) ))"."$(($k+$(( ${iparr[2]} & ${netmaskarr[2]})) ))"."$(($l+$((${iparr[3]} & ${netmaskarr[3]})) )) )
        		done
      		done
		done
  	done
}

network_address_to_ips $IP_ADDR/$IP_CIDR

if [ ! -f $vendorlist ]; then
        echo "stahuji seznam vyrobcu MAC adres..."
	wget -O $vendorlist http://standards-oui.ieee.org/oui.txt
fi

echo "Jsme $IP_ADDR/$IP_CIDR, jdeme pingnout nasi sit, celkem ${#ips[@]}-1 ip..."
for ip in "${ips[@]}"; do
	if [ "$ip" != "$IP_BRD" ]; then
		timeout 0.3 ping -c 1 $ip > $tmp0 
		if [ $? -eq 0 ]; then
			ttl=$(grep -i "ttl\=" $tmp0|awk '{print $6}' | cut -d= -f2)
			resp=$(grep -i "ttl\=" $tmp0|awk '{print $7}')
			mac=$(grep "${ip}\ " /proc/net/arp|awk '{print $4}'|grep -P '^(?!fe80)'|tr -d ':'|head -c6)
			if [ "$mac" == '' ]; then
				vendor=""
			else
				vendor=$(grep -i "${mac}" $vendorlist | cut -d\) -f2 | tr -d '\t')
			fi
			echo  "$ip odpovedel ${resp/time\=/za\ } milisekund | $(core_determine $ttl) | ${vendor}"
		fi
	else
		echo "$ip vynechavame (broadcast)"
	fi
done

rm -f $tmp0
