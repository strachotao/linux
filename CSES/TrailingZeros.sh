#!/bin/bash
# https://cses.fi/problemset/task/1618
num=$1
fact=1
zeroCount=0

for (( i=1; i<=$num; i++)); do
	fact=$(( fact*i ))
done

for (( i=${#fact}; i>=0; i-- )); do
	if [[ ${fact:$i-1:1} -eq 0 ]]; then
		((zeroCount++))
	else
		break	
	fi
done

echo $zeroCount
