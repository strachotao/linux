#!/bin/bash
# https://cses.fi/problemset/task/1637
n=$1
count=0
until [[ $n -eq 0 ]]; do
	for (( i=${#n}; i>0; i-- )); do
		if [[ ${n:i-1:1} -gt 0 ]]; then
			n=$((n-${n:i-1:1}))
			((count++))
		fi
	done
done

echo $count
