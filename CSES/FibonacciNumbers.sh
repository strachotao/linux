#!/bin/bash
# https://cses.fi/problemset/task/1722
input=$1 
N=$input
a=0; b=1  
   
for (( i=0; i<N; i++ )); do
    fn=$((a + b)) 
    a=$b 
    b=$fn 
done

echo $a
