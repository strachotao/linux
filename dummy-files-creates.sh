#!/bin/bash
# bulk dummy files; version 2018-01-17; strachotao
# 
#   wget https://raw.githubusercontent.com/strachotao/linux/master/dummy-files-creates.sh
#
#   TODO:

usage() {
	echo "Usage: $0 {size in MB} [size in MB] ... [size in MB]"
	echo
	echo "Examples: $0 100"
	echo "          $0 10 10 10 10"
	echo
	echo "Desc: creates a dummy file(s) which does not have any real data"
	echo "Output name format: dummyfile-$(echo `date '+%Y-%m-%d--%H:%M:%S:%N'`)"
	exit 1
}

if [[ $# -lt 1 ]]; then
	usage
fi

RE='^[0-9]+$'

for SIZE in $@
do
	if ! [[ $SIZE =~ $RE ]] ; then
		echo "Error: $SIZE is not a number"
		continue	
	fi
	DATE=`date '+%Y-%m-%d--%H:%M:%S:%N'`
	dd if=/dev/zero of=./dummyfile-${DATE} bs=4k iflag=fullblock,count_bytes count=${SIZE}M
done

ls -l
