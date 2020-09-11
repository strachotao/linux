#!/bin/bash
# https://cses.fi/problemset/task/1068
result="$1 "
n=$1
until [[ $n -eq 1 ]]; do
	if [[ $((n%2)) -eq 0 ]]; then
		n=$((n/2))
	else
		n=$((n*3+1))
	fi
	result="$result $n "
done

echo $result
