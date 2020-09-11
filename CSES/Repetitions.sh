#!/bin/bash
#https://cses.fi/problemset/task/1069
input=$1
values=()
for (( i=0; i<${#input}; i++ )); do
	letter=${input:$i:1}
	counter=1
	if [[ "$letter" == "${input:$i+1:1}" ]]; then
		((counter++))
		for (( n=i+2; n<${#input}; n++ )); do
			if [[ "$letter" == "${input:$n:1}" ]]; then
				((counter++))
			else
				values+=($counter)
				break	
			fi
		done
		values+=($counter)
	else
		values+=(1)
		continue
	fi
done

top=${values[0]}
for x in "${values[@]}" ; do
	if [[ $x -gt $top ]]; then
		top=$x
	fi
done

echo $top
