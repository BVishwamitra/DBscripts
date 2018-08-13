# Author       : Srinivasarao Oguri
# Date         : 13-Aud-2018
# Description  : This script is used to create the database with minium amount of space and time. change the ORACLE HOME according to your environment. 
# Usage : sh /home/oracle/create_database.sh <ORACLE_SID>
#!/bin/bash
export ORACLE_HOME=/home/oracle/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=$1
export PATH=$ORACLE_HOME/bin:$PATH

echo "Starting time : `date`" > /home/oracle/logcreatedb.txt
echo "DB_NAME=$1" > $ORACLE_HOME/dbs/init$ORACLE_SID.ora
echo "DB_CREATE_FILE_DEST='/home/oracle/app/oracle/oradata'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
echo "DB_CREATE_ONLINE_LOG_DEST_1='/home/oracle/app/oracle/oradata'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora
echo "CONTROL_FILES='/home/oracle/app/oracle/oradata/controlfiles/"$ORACLE_SID"ctrl.ctl'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora


sqlplus / as sysdba <<EOF
startup nomount;
create database $1
logfile group 1 size 10M,
            group 2 size 10M,
            group 3 size 10M
character set AL32UTF8
national character set utf8
datafile size 10M autoextend on next 1M maxsize unlimited extent management local
sysaux datafile size 10M autoextend on next 1M maxsize unlimited
undo tablespace undotbs1 datafile size 10M
default temporary tablespace temp tempfile size 10M;
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
EOF
echo "Ending time : `date`" >> /home/oracle/logcreatedb.txt
