#!/bin/bash
# decimal zip; ver 2021-05-17; strachotao 

A=$1; B=$2

for (( i=0; i<${#A} || i<${#B}; i++ )); do
	num+="${A:${i}:1}${B:${i}:1}"
done

if (( num > 100000000 )); then
	echo "-1"
	exit 0
fi

if [ ! -z "$num" ]; then
	echo $num
fi
