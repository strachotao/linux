#!/bin/bash
# oracle txt dashboard; version 2018-03-22; strachotao

export ORACLE_SID_SMALL=$(echo $ORACLE_SID | tr '[:upper:]' '[:lower:]')

info="${ORACLE_SID} DATABASE BACKUP DASHBOARD, strachotao v20180322, last updated on:  "
watchdelay=10

arch_log_show_lines=6
alert_log_show_lines=23
title_last_arc_backup="Last two archlogs backup from /var/log/oracle/${ORACLE_SID}/backup/archlog_backup.log"
title_last_full_backup="Last full/incremental backup /var/log/oracle/${ORACLE_SID}/backup/full_backup.log"
title_cat11="Last CAT11 export log /var/log/oracle/CAT11/backup/expdp.log"

watch -t -d -n $watchdelay "\
echo -ne $info && date '+%Y.%m.%d  %k:%M:%S' &&\
uptime &&\
top -bn 2 -d 0.01 | grep 'Cpu(s)' | tail -n 1 &&\
echo " " &&\
tail -n $arch_log_show_lines /var/log/oracle/${ORACLE_SID}/backup/archlog_backup.log &&\
printf '\n' &&\
echo $title_last_arc_backup &&\
cat /var/log/oracle/${ORACLE_SID}/backup/archlog_backup.log | grep -i "done" | tail -n 2 &&\
printf '\n' &&\
echo $title_last_full_backup &&\
cat /var/log/oracle/${ORACLE_SID}/backup/full_backup.log | tail -n 4 &&\
printf '\n' &&\
echo $title_cat11 &&\
cat /var/log/oracle/CAT11/backup/expdp.log | tail -n 4 &&\
printf '\n\n' &&\
df -Ph /u04/oradata/DB1 &&\
df -Ph /u11/oradata/DB2 &&\
printf '\n\n' &&\
echo /u00/app/oracle/diag/rdbms/${ORACLE_SID_SMALL}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log &&\
tail -n $alert_log_show_lines /u00/app/oracle/diag/rdbms/${ORACLE_SID_SMALL}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log"
