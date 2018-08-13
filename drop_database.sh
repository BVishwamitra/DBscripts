# Author       : Srinivasarao Oguri
# Date         : 13-Aud-2018
# Description  : This script is used to create the database with minium amount of space and time. change the ORACLE HOME according to your environment. 
# Usage : sh /home/oracle/drop_database.sh <ORACLE_SID>
#!/bin/bash
export ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=$1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / <<EOF
startup force mount;
SQL 'ALTER SYSTEM ENABLE RESTRICTED SESSION';
drop database including backups noprompt;
exit;
EOF
