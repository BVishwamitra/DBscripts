# Author       : Srinivasarao Oguri
# Date         : 13-Aug-2018
# Description  : This script is used to run the sqlfile we got by ddl extractor.
#!/bin/bash
file=$1
echo > /home/oracle/create_tablespace.sql
for i in $(egrep 'CREATE TABLESPACE .* DATAFILE|CREATE .* TABLESPACE .* DATAFILE' $file | grep -v UNDO | grep -v TEMPORARY | awk '{print $(NF-1)}')
do
echo " create tablespace $i datafile size 1M autoextend on; " >> /home/oracle/create_tablespace.sql
done

for i in $(egrep 'CREATE TABLESPACE .* DATAFILE|CREATE .* TABLESPACE .* DATAFILE' $file | egrep 'TEMPORARY' | awk '{print $(NF-1)}')
do
echo " create TEMPORARY tablespace $i tempfile size 10M autoextend on; " >> /home/oracle/create_tablespace.sql
done

for i in $(egrep 'CREATE TABLESPACE .* DATAFILE|CREATE .* TABLESPACE .* DATAFILE' $file | egrep 'UNDO'| awk '{print $(NF-1)}')
do
echo " create UNDO tablespace $i datafile size 1M autoextend on; " >> /home/oracle/create_tablespace.sql
done
[oracle@localhost ~]$ cat load.sh 
usage()
{
cat <<EOF
Usage: `basename $0` -c <username/password@sid> -s <sql_file_name> -l <log_file_location>		
-c     Oracle user credentials who has admin permission
-s     SQL file with schema dump
-l     Location of logfile
EOF
   exit 1
}

simple_usage()
{
   echo -e "Usage: `basename $0` -c <username/password@sid> -s <sql_file_name> -l <log_file_location>\n"
   exit
}

# Validate the options passed

validate()  #-- Validate the script options
{
   if [ -z "${conn}" ] || [ -z "${sql_file_name}" ] || [ -z "${log_file_location}" ]; then
      simple_usage
   fi
  
   if [ ! -f "$sql_file_name" ]; then
      echo -e "\t\nNo file exists with name $sql_file_name"
      simple_usage
   fi
   if [ ! -d "${log_file_location}" ]; then
      echo -e "\t\n'$log_file_location' Not a directory.. Please pass the right one"
      simple_usage
   fi
}

## Storing the option values
#---------------------------


while getopts ":c:s:l:h:" opt; do
    case "${opt}" in
         c)
            conn=${OPTARG}
            ;;
         s)
            sql_file_name=${OPTARG}
            ;;
         l)
            log_file_location=${OPTARG}
            ;;
         h)
            usage
            ;;
         \?) 
            echo "Unknown option: -$OPTARG" >&2 
            echo "check the ./`basename $0` -help for details"
            exit
            ;;
     esac
done


create_schema()
{
sqlplus -s ${conn} <<EOF
drop user $schema_name cascade;
create user $schema_name identified by password;
grant dba to $schema_name;
alter session set current_schema = $schema_name;
START $sql_file_name;
EOF
}

validate

export ORACLE_HOME=/home/oracle/app/oracle/product/12.1.0/dbhome_1
export ORACLE_SID=orcl
export PATH=/home/oracle/app/oracle/product/12.1.0/dbhome_1/bin:$PATH
# The sql file format is "<path>/DBNAME_SCHEMANAME_ddl.sql", This script will extract the dbname_schemaname and create a schema with that name(dbname_schemaname).
schema_name=$(echo $sql_file_name | awk -F'/' '{print $NF}' | sed s/_ddl.sql// | awk '$1=" "' FS=_ OFS=_ | sed s/'^ _//')
#schema_name=$(echo $sql_file_name | awk -F'/' '{print $NF}' | sed s/_ddl.sql//)
#schema_name=$(echo $sql_file_name | awk -F'/' '{print $NF}' | cut -d'.' -f1 | sed s/_ddl.sql//)
exec > $log_file_location/"$schema_name".log 2>&1

create_schema
RET=$?

exec > /dev/tty
if [ $RET -ne 0 ]
then
echo "Some errors/warnings, look the logfile : $log_file_location/"$schema_name".log"
else
echo "Schema creation/loading is successful : $sql_file_name"
fi
