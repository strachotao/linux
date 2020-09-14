#!/bin/bash
# https://cses.fi/problemset/task/1753

x=0

read string
read pattern

string=${string//${pattern}/1}
n=${string//[^[:digit:]]/}

for (( i=0; i<${#n}; i++ )); do
	x=$((x+${n:i:1}))
done

echo $x
