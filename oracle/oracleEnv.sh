#!/bin/bash
export ORACLE_SID=$1
export ORACLE_SID_SMALL=`echo $ORACLE_SID | tr '[:upper:]' '[:lower:]'`
env | grep -v PS1 | grep -i oracle_
