alias wat="/home/oracle/ostracho/watch_arc_logs.sh"
alias sql='sqlplus "/as sysdba"'
alias bu='cd /u00/backupscripts'
alias bul="cd /var/log/oracle/\$ORACLE_SID/backup"
alias hom="cd $(get-ORACLE_HOME)"
alias lis='echo "ps -ef | grep -i listener"&&ps -ef | grep -i [l]istener'
alias dat="cd /u00/oradata/\$ORACLE_SID"
alias ins='echo "cd /u00/install"&& cd /u00/install'
alias log="ll /u04/oradata/DB1/arch* && ll /u04/oradata/DB1/arch* | wc -l && df -h /u04/oradata/DB1 && date '+%Y.%m.%d %k:%M:%S'"
alias alert="tail -n 40 /u00/app/oracle/diag/rdbms/\$ORACLE_SID_SMALL/\$ORACLE_SID/trace/alert_\$ORACLE_SID.log && ls -l /u00/app/oracle/diag/rdbms/\$ORACLE_SID_SMALL/\$ORACLE_SID/trace/alert_\$ORACLE_SID.log"
alias DB1='dir=$(/bin/pwd) && cd /bin && source ./oracleEnv.sh DB1 && cd $dir'
alias CAT11='dir=$(/bin/pwd) && cd /bin && source ./oracleEnv.sh CAT11 && cd $dir'
