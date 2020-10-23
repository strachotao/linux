/*

rozlozeni disku po vytvoreni instance


Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/mapper/vg01-lv_root
              ext4   1008M  534M  424M  56% /
tmpfs        tmpfs     16G     0   16G   0% /dev/shm
/dev/sda1     ext4    124M   46M   73M  39% /boot
/dev/mapper/vg01-lv_home
              ext4   1008M   46M  912M   5% /home
/dev/mapper/vg01-lv_opt
              ext4    4.0G  1.4G  2.5G  36% /opt
/dev/mapper/vg01-lv_tmp
              ext4    2.0G   68M  1.9G   4% /tmp
/dev/mapper/vg01-lv_u00
              ext4     22G  9.6G   11G  48% /u00
/dev/mapper/vg01-lv_u99
              ext4     11G  155M  9.9G   2% /u99
/dev/mapper/vg01-lv_usr
              ext4    3.0G  1.1G  1.8G  37% /usr
/dev/mapper/vg01-lv_var
              ext4    2.0G  401M  1.5G  21% /var
/dev/mapper/vg01-lv_crash
              ext4    5.0G  138M  4.6G   3% /var/crash
/dev/mapper/vg_DB1-lvol0
              ext4    493G  393G   95G  81% /u01/oradata/DB1
/dev/mapper/vg_DB1-lvol1
              ext4    394G  249G  142G  64% /u02/oradata/DB1
/dev/mapper/vg_DB1-lvol2
              ext4     20G  5.7G   14G  30% /u03/oradata/DB1
/dev/mapper/vg_DB1-lvol3
              ext4     30G  4.6G   25G  16% /u04/oradata/DB1
/dev/mapper/vg_DB1-lvol4
              ext4    128G   31G   97G  25% /u05/oradata/DB1
/dev/mapper/vg02-lvol0
              ext4    394G  199M  390G   1% /db1
/dev/mapper/vg02-lvol1
              ext4    512G  316G  192G  63% /tmp/MIG

*/






set echo on
spool crdb_db1.log

startup nomount pfile=/u00/app/oracle/product/11.2.0/dbhome_1/dbs/initDB1.ora force

create database DB1
controlfile reuse
logfile group 1 ('/u00/oradata/DB1/redo01.log') size 32767k reuse,
        group 2 ('/u00/oradata/DB1/redo02.log') size 32767k reuse,
        group 3 ('/u00/oradata/DB1/redo03.log') size 32767k reuse,
        group 4 ('/u00/oradata/DB1/redo04.log') size 32767k reuse,
        group 5 ('/u00/oradata/DB1/redo05.log') size 32767k reuse,
        group 6 ('/u00/oradata/DB1/redo06.log') size 32767k reuse,
        group 7 ('/u00/oradata/DB1/redo07.log') size 32767k reuse,
        group 8 ('/u00/oradata/DB1/redo08.log') size 32767k reuse
datafile '/u00/oradata/DB1/system01.dbf' size 2048M reuse
sysaux datafile '/u00/oradata/DB1/sysaux01.dbf' size 3072M reuse
undo tablespace UNDOTBS datafile '/u00/oradata/DB1/undo01.dbf' size 4096M reuse,
                                 '/u00/oradata/DB1/undo02.dbf' size 4096M reuse
character set EE8ISO8859P2
national character set AL16UTF16;

create tablespace USER_DATA
datafile '/u00/oradata/DB1/userdata01.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata02.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata03.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata04.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata05.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata06.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata07.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata08.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata09.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata10.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata11.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata12.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata13.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata14.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata15.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata16.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata17.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata18.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata19.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata20.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata21.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata22.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata23.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata24.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata25.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata26.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata27.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata28.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata29.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata30.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata31.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata32.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata33.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata34.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata35.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata36.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata37.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata38.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata39.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata40.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata41.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata42.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata43.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata44.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata45.dbf' size 8192M reuse,
        '/u00/oradata/DB1/userdata46.dbf' size 8192M reuse
extent management local autoallocate;

create tablespace USER_IDX
datafile '/u00/oradata/DB1/usridx01.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx02.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx03.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx04.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx05.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx06.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx07.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx08.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx09.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx10.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx11.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx12.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx13.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx14.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx15.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx16.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx17.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx18.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx19.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx20.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx21.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx22.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx23.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx24.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx25.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx26.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx27.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx28.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx29.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx30.dbf' size 8192M reuse,
        '/u00/oradata/DB1/usridx31.dbf' size 8192M reuse
extent management local autoallocate;

create tablespace DB13
datafile '/u00/oradata/DB1/db13_01.dbf' size 8192M reuse,
         '/u00/oradata/DB1/db13_02.dbf'size 8192M reuse,
         '/u00/oradata/DB1/db13_03.dbf'size 8192M reuse
extent management local autoallocate;

create tablespace TASK
datafile '/u00/oradata/DB1/task01.dbf' size 204800k reuse
extent management local autoallocate;

create tablespace TOOLS
datafile '/u00/oradata/DB1/tools01.dbf' size 262140k reuse;

create tablespace RBS
datafile '/u00/oradata/DB1/rbs01.dbf' size 4096M reuse,
         '/u00/oradata/DB1/rbs02.dbf' size 4096M reuse
        EXTENT MANAGEMENT LOCAL
        SEGMENT SPACE MANAGEMENT manual;

create rollback segment R_sys tablespace "SYSTEM" storage (initial 1M next 1M optimal 3M MAXEXTENTS UNLIMITED);
alter rollback segment R_sys online;
create public rollback segment R01 tablespace "RBS" storage (initial 10M next 10M optimal 80M MAXEXTENTS UNLIMITED);
create public rollback segment R02 tablespace "RBS" storage (initial 10M next 10M optimal 80M MAXEXTENTS UNLIMITED);
create public rollback segment R03 tablespace "RBS" storage (initial 10M next 10M optimal 80M MAXEXTENTS UNLIMITED);
create public rollback segment R04 tablespace "RBS" storage (initial 10M next 10M optimal 80M MAXEXTENTS UNLIMITED);

alter rollback segment R01 online;
alter rollback segment R02 online;
alter rollback segment R03 online;
alter rollback segment R04 online;

alter rollback segment R_sys offline;

create temporary tablespace TEMP
tempfile '/u00/oradata/DB1/temp01.dbf' size 8192M reuse,
         '/u00/oradata/DB1/temp02.dbf' size 8192M reuse,
         '/u00/oradata/DB1/temp03.dbf' size 8192M reuse,
         '/u00/oradata/DB1/temp04.dbf' size 8192M reuse,
         '/u00/oradata/DB1/temp05.dbf' size 8192M reuse,
         '/u00/oradata/DB1/temp06.dbf' size 8192M reuse
extent management local uniform size 10M;

alter user sys identified by sys temporary tablespace TEMP;

/*
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/sqlplus/admin/pupbld.sql
*/

disconnect

spool off

exit
