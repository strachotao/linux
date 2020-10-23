#!/bin/bash
# DB1_archlogs_backup.sh; version 2013-09-29; strachotao

ORACLE_SID="DB1"
archdir="/u04/oradata/DB1/*.arc"

ORACLE_BASE="/u00/app/oracle"
ORACLE_HOME=$(get-ORACLE_HOME)
PATH=$PATH:${ORACLE_HOME}/bin
usr="rman92"
pass="*******************"
cat="cat11"
lock_file="/home/oracle/.backupInProgress"

# wait (in seconds) to next archlogs count check
wait_time=60
# do backup if count of the archlogs equals or is greather then $log_count_treshold
log_count_treshold=120
# do backup every $counter_treshold minutes if archlogs count don't reach $log_count_treshold
counter_treshold=30

function get-date {
    timestamp=`/bin/date '+%Y.%m.%d %H:%M:%S'`
    echo $timestamp
}

function doBackup(){
    rman target / catalog $usr/$pass@$cat log=$log << EOF1
    CONFIGURE DEFAULT DEVICE TYPE TO 'SBT_TAPE';
    CONFIGURE DEVICE TYPE 'SBT_TAPE' BACKUP TYPE TO BACKUPSET PARALLELISM 2;
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 40 DAYS;
    SET ECHO OFF;
    run
    {
    sql "alter system archive log current";
    backup as backupset filesperset 20 archivelog all delete all input format 'arc_%d_%T_t%t_s%s_p%p' TAG=ARCLOG;
    }
    EXIT;
EOF1
}

counter=0

while :
do
    stamp=`/bin/date '+%Y-%m-%d__%H-%M-%S__'`
    backtype="_archlog_"
    log="/var/log/oracle/$ORACLE_SID/backup/$stamp$backtype$ORACLE_SID.log"
    arclog="/var/log/oracle/$ORACLE_SID/backup/archlog_backup.log"
    logcount=`/bin/ls -l $archdir | /usr/bin/wc -l`

    if [ "$logcount" -ne 0 ]; then
        if [[ "$logcount" -ge "$log_count_treshold" || "$counter" -ge "$counter_treshold" ]]; then
            /bin/echo "[`get-date`] Log count = $logcount/$log_count_treshold | Counter = $counter/$counter_treshold" >> $arclog
            /bin/echo "[`get-date`] Starting backup..." >> $arclog
            counter=0
            while [ -f ${lock_file} ]
            do
                sleep 60
                echo "[`get-date`] Some backup is already running, waiting..." >> $arclog
            done
            echo "[`get-date`] Creating lock file ${lock_file}" >> $arclog
            echo "archlogbackup" > ${lock_file}
            doBackup
            ret_code=$?
            rm -f ${lock_file}
            logcount=`/bin/ls -l $archdir | /usr/bin/wc -l`            
            if [ $ret_code -eq 0 ]; then
                /bin/echo "[`get-date`] Done OK - return code $ret_code" >> $arclog
            else
                /bin/echo "[`get-date`] Done ERROR - return code $ret_code" >> $arclog
                /bin/df -hT "/u04/oradata/$ORACLE_SID" >> $log
                LANG= /bin/mail -r "$ORACLE_SID" -s "Archlog backup error $ret_code" "admin@domain.cz" < $log
            fi
        fi
    fi
  
    /bin/echo "[`get-date`] Log count = $logcount/$log_count_treshold | Counter = $counter/$counter_treshold" >> $arclog
    
    /bin/sleep $wait_time
    ((counter++))

done
