#!/bin/bash
# hw-info; version 2020-06-05; strachotao
#
#  short HW info:
#    hw-info-placeholder,hostname,cpu(s),ram(M),san(G)

placeholder="serverhw" #useful for grep
srv=$(hostname)
san=$(df -P -BG --total --local|grep "^total"|awk '{print $2}'|sed 's/G//')
ram=$(free -m|grep "^Mem\:"|awk '{print $2}')
cpu=$(lscpu|grep "^CPU(s)"|awk '{print $2}')

echo "$placeholder,$srv,$cpu,$ram,$san"
