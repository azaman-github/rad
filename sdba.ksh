#####################################################################################
# Name     : sdba.ksh
# Overview : The script automates snowflake database administration tasks
# Notes    :
#
# Change History
# -----------------------------------------------------------------------------------
# Date         Author     Description
# ------------------------------------------------------------------------------------
# 17/02/2025   A Zaman    Initial creation
######################################################################################
#
#
#
########################################################################################
# Name     : initialise_variables 
# Overview : The function initialises all global variables.
# Notes :
#########################################################################################
initialise_variables()
{ 
#                                               
#
export TEMP_DIR=/tmp
export SQL_SCRIPT=${TEMP_DIR}/dba_script_$$.sql
export REPORT_FILE=${TEMP_DIR}/dba_report_$$.txt
export TEMP_FILE_1=${TEMP_DIR}/dba_temp_1_$$.txt
export TEMP_FILE_2=${TEMP_DIR}/dba_temp_2_$$.txt
export TEMP_FILE_3=${TEMP_DIR}/dba_temp_3_$$.txt
export LOG_FILE=${TEMP_DIR}/dba_$$.log
export DATA_FILE_1=${TEMP_DIR}/contact.csv
export UNLOADED_FILE=${DATA_FILE_1}.gz
export OUTER_WRAPPER_SCRIPT=${TEMP_DIR}/outer_wrapper_$$.ksh

export SNOWSQL_ACCOUNT="du86785.eu-west-2.aws"
export SNOWSQL_USER=azaman
export SNOWSQL_PWD=Nurmak01__
export DATABASE=scratcH
export SCHEMA=dba_practice
export CONNECT_STRING=" -a ${SNOWSQL_ACCOUNT}  -u  ${SNOWSQL_USER}  -d ${DATABASE} -s ${SCHEMA} -f ${SQL_SCRIPT}"
#
export TRUE=0
export FALSE=1
}
#
#
#
#######################################################################################################
# Name     : get_yn_acknowledgement
# Overview : The function is used to get Y/N acknowledgement from user.
# Input    : string (message to be displayed)
# Notes    :
#######################################################################################################
get_yn_acknowledgement ()
{
#
export TRUE=0
export FALSE=1
#
##
P_MSG="${1}"
while true
do
  clear
  echo -n "${P_MSG}"
  read INPUT
  case $INPUT  in
     y|Y) return $TRUE ;;
     n|N) return $FALSE ;;
      *) echo -n "Invalid value entered;press any key to continue";
         read DUMMY ;
         continue ;;
  esac
done
#
}
#
#
#
########################################################################################
# Name     : execute_script_and_view_report
# Overview : The function executes a sql script and allow user the view the report.
# Notes :
#########################################################################################
execute_script_and_view_report()
{
echo -n "Executing the sql script;press any key to continue..."
read DUMMY
snowsql ${CONNECT_STRING}   > ${REPORT_FILE}  2>&1
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
}
#
#
#######################################################################################
# Name     : execute_dynamically_generated_script
# Overview : The function executes dynamically generated script.
# Notes    : 1. The following script is dynamically generated:
#                       - OUTER_WRAPPER_SCRIPT
#            2. The script can be viewed and executed as many times as required.             
########################################################################################
execute_dynamically_generated_script()
{
chmod +x  ${OUTER_WRAPPER_SCRIPT}
while true
do
   clear
   echo -n "View/Edit the script that will be run;press any key to continue..."
   read DUMMY
   view ${OUTER_WRAPPER_SCRIPT}
   clear
   echo -n "Executing the script..."
   ${OUTER_WRAPPER_SCRIPT}
   if  get_yn_acknowledgement "Do you wish to continue with viewing/Editing(Y/N):"
   then
        continue
   else
        break
   fi
done
#
#
}
#
#
#
########################################################################################
# Name     : list_all_active_users
# Overview : The function list all active users
# Notes :
#########################################################################################
list_all_active_users()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True

SELECT name, created_on,first_name, last_name,snowflake_lock, has_mfa,expires_at
FROM snowflake.account_usage.users
WHERE deleted_on is null
ORDER by name;
EOF2
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                List of All Active Users"  > ${REPORT_FILE}
echo "                ========================"  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : create_user
# Overview : The function creates an user
# Notes :
#########################################################################################
create_user()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True

/*
Access control requirements
===========================
A role used to execute this operation must have the following privileges at a minimum:

Privilege           Object         Notes
CREATE USER         Account        Only the USERADMIN role, or a higher role, has this privilege by default. The privilege can be granted to
                                   additional role as needed.

User with default Values
========================
Create a user with all default properties, a default role, and a basic password that must be changed by the user after their first login:


CREATE [ OR REPLACE ] USER [ IF NOT EXISTS ] <name>
  [ objectProperties ]
  [ objectParams ]
  [ sessionParams ]
  [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]

Where :
objectProperties ::=
  PASSWORD = '<string>'
  LOGIN_NAME = <string>
  DISPLAY_NAME = <string>
  FIRST_NAME = <string>
  MIDDLE_NAME = <string>
  LAST_NAME = <string>
  EMAIL = <string>
  MUST_CHANGE_PASSWORD = TRUE | FALSE
  DISABLED = TRUE | FALSE
  DAYS_TO_EXPIRY = <integer>
  MINS_TO_UNLOCK = <integer>
  DEFAULT_WAREHOUSE = <string>
  DEFAULT_NAMESPACE = <string>
  DEFAULT_ROLE = <string>
  DEFAULT_SECONDARY_ROLES = ( 'ALL' ) | ()
  MINS_TO_BYPASS_MFA = <integer>
  RSA_PUBLIC_KEY = <string>
  RSA_PUBLIC_KEY_FP = <string>
  RSA_PUBLIC_KEY_2 = <string>
  RSA_PUBLIC_KEY_2_FP = <string>
  TYPE = PERSON | SERVICE | LEGACY_SERVICE | NULL
  COMMENT = '<string_literal>'

objectParams ::=
  ENABLE_UNREDACTED_QUERY_SYNTAX_ERROR = TRUE | FALSE
  ENABLE_UNREDACTED_SECURE_OBJECT_ERROR = TRUE | FALSE
  NETWORK_POLICY = <string>

sessionParams ::=
  ABORT_DETACHED_QUERY = TRUE | FALSE
  AUTOCOMMIT = TRUE | FALSE
  BINARY_INPUT_FORMAT = <string>
  BINARY_OUTPUT_FORMAT = <string>
  DATE_INPUT_FORMAT = <string>
  DATE_OUTPUT_FORMAT = <string>
  ERROR_ON_NONDETERMINISTIC_MERGE = TRUE | FALSE
  ERROR_ON_NONDETERMINISTIC_UPDATE = TRUE | FALSE
  JSON_INDENT = <num>
  LOCK_TIMEOUT = <num>
  QUERY_TAG = <string>
  ROWS_PER_RESULTSET = <num>
  SIMULATED_DATA_SHARING_CONSUMER = <string>
  STATEMENT_TIMEOUT_IN_SECONDS = <num>
  STRICT_JSON_OUTPUT = TRUE | FALSE
  TIMESTAMP_DAY_IS_ALWAYS_24H = TRUE | FALSE
  TIMESTAMP_INPUT_FORMAT = <string>
  TIMESTAMP_LTZ_OUTPUT_FORMAT = <string>
  TIMESTAMP_NTZ_OUTPUT_FORMAT = <string>
  TIMESTAMP_OUTPUT_FORMAT = <string>
  TIMESTAMP_TYPE_MAPPING = <string>
  TIMESTAMP_TZ_OUTPUT_FORMAT = <string>
  TIMEZONE = <string>
  TIME_INPUT_FORMAT = <string>
  TIME_OUTPUT_FORMAT = <string>
  TRANSACTION_DEFAULT_ISOLATION_LEVEL = <string>
  TWO_DIGIT_CENTURY_START = <num>
  UNSUPPORTED_DDL_ACTION = <string>
  USE_CACHED_RESULT = TRUE | FALSE
  WEEK_OF_YEAR_POLICY = <num>
  WEEK_START = <num>

*/
--
--
create user u1
password = "p1"
must_change_password = True
default_role = role1;

EOF2
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                List of All Active Users"  > ${REPORT_FILE}
echo "                ========================"  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : display_user_management_menu
# Overview : The function displays user management menu.
# Notes :
#########################################################################################
display_user_management_menu()
{
#                                               
MENU_NAME=usrm

while 
true
do
   clear
   echo  "
##############################################
#             User Management Menu           #
#                                            #
#  5. List All Active Users                  #
# 10. Create User                            #
#                                            #
# 98. Root Menu                              #
# 99. Exit                                   #
#                                            # 
##############################################"
echo  -n "Enter Option-->"
read MENU_OPTION
process_menu_option

done
#                                                   
#
}
#
#
#
#
#
########################################################################################
# Name     : list_all_roles
# Overview : The function list roles
# Notes :
#########################################################################################
list_all_roles()
{
cat  <<EOF  > ${SQL_SCRIPT}                                               

SELECT name,created_on, role_type, owner, owner_role_type
FROM snowflake.account_usage.roles
WHERE deleted_on is null and 
      owner is not NULL  and -- exclude system defined users
       role_type in ('ROLE','DATABASE_ROLE')
ORDER by name;

EOF
#
execute_script_and_view_report
#
}
#
#
########################################################################################
# Name     : list_all_grants_for_roles
# Overview : The function list all grants for roles
# Notes :
#########################################################################################
list_all_grants_for_roles()
{
#
clear
echo -n "Working..."
#
#get a list of all roles
#
cat  <<EOF  > ${SQL_SCRIPT}                                               

SELECT '#START#';
SELECT name
FROM snowflake.account_usage.roles
WHERE deleted_on is null and 
owner is not NULL  and -- exclude system defined users
role_type in ('ROLE','DATABASE_ROLE') 
order by name;
SELECT '#END#';

EOF
#
snowsql ${CONNECT_STRING}  > ${TEMP_FILE_1} 2>&1

cd ${TEMP_DIR}
csplit  ${TEMP_FILE_1}   /#START#/+8    /#END#/-3 >/dev/null 2>&1
cat  xx01 | sed s/'| '//g | sed s/$' '.*// > ${TEMP_FILE_2} #<-- list of roles

echo "                           List of All Grants to All Roles"> ${TEMP_FILE_1}
echo "                           ==============================">> ${TEMP_FILE_1}
#
# for each role, retrieve all grants
# 
cat ${TEMP_FILE_2} | while read ROLE_NAME
do
   cat <<EOF > ${SQL_SCRIPT}  2>&1
   SELECT '#START#' ;
   show grants to role ${ROLE_NAME};
   SELECT '#END#' ;
EOF

   snowsql ${CONNECT_STRING}  > ${TEMP_FILE_3}  2>&1

   csplit  ${TEMP_FILE_3}   /#START#/+5    /#END#/ > /dev/null 2>&1

   echo "Grants on Role-${ROLE_NAME}"    >> ${TEMP_FILE_1}
   echo "==============================" >> ${TEMP_FILE_1}
   cat xx01      >> ${TEMP_FILE_1}
   echo -e "\n"  >> ${TEMP_FILE_1}
done

cat ${TEMP_FILE_1}  | sed s/'+---------+'// >  ${REPORT_FILE}
vi  ${REPORT_FILE} 

#
}
#
#                                       
########################################################################################
# Name     : display_role_management_menu
# Overview : The function displays role management menu.
# Notes :
#########################################################################################
display_role_management_menu()
{
#                                               
MENU_NAME=rolm

while true
do
clear
echo  "
##############################################
#            Role Management Menu           #
#                                            #
#  5. List All Roles                         #
# 10  List All Grants for Roles              #
#                                            #
# 98. Root Menu                              #
# 99. Exit                                   #
#                                            # 
##############################################"
echo  -n "Enter Option-->"
read MENU_OPTION
process_menu_option

done
#                                                   
#
}
#
#
########################################################################################
# Name     : time_travel_and_failsafe_primer()
# Overview : The function displays a primer on time travel and failsafe concepts.
#
# Notes    : 
#########################################################################################
time_travel_and_failsafe_primer()
{
#
cat <<EOF  >  ${TEMP_FILE_1}

Important Information
=====================
1. Default TT period is 1 day for all types of tables
2. TT period can be set to 0 which will deactivate TT mechanism.
3. A non configurable period of 7 days  ( can not be changed) is applied as FS period for permanent table
4. There is no file safe period for transient and temporary tables
5. TT period can be extended upto 90 days for enterprice edition.
6. Following two parameters are used to control TT period:
           - DATA_RETENTION_TIME_IN_DAYS 
           - MIN_DATA_RETENTION_TIME_IN_DAYS


Understanding & using Time Travel
=================================

1. Snowflake Time Travel enables accessing historical data (i.e. data that has been changed or deleted) at any point within a defined period. 

2. It serves as a powerful tool for performing the following tasks:

          - Restoring data-related objects (tables, schemas, and databases) that might have been accidentally or intentionally deleted.

          -  Duplicating and backing up data from key points in the past.

          - Analyzing data usage/manipulation over specified periods of time.

3. It acts like online backup

How does it work ?
==================
                                                                   table is dropped
                                                                           |
 <-------------first day------><----- second day----><------third day-----><----fourth day------->
 ---------------------------------------------------------------------------------------------------------------------->Time
|                             |                      |                     |                     |
T0                            T1                     T2                    T3                   T4
Table                         <----------------------><-----=--------------><--------------------->
created                        data beteen T0 and T1  data between T0        data between T2 and T3
with data                      is available           and T1 not available   available
retention period = 1                                  data between T1 and T2
                                                      is available

Table Type                  TT Allowed        Default TT  Can be altered to     Fail Safe
Transient                   Maximum 1  day     1 day          0                  0
Temporary                   Maximum 1  day     1 day          0                  0
Permanent(standard)         Maximum 1  day     1 day          0                  7 days                 
Permanent(Enterprise)       Maximum 90 days    1 day          0                  7 days                 

Notes
1. When you define data_retention_time_in_days, this works on continuous basis as shown above.
2. Metadata will continue to show retention time for table that has TT defined.
3. Metadata will continue to show failsafe bytes, once the table enters failsafe.
4. Table enter failsafe, at the first expiry of time travel.
5. Data for both time travel and fail safe will vary  because the volume of data in table might increase.
6. Remember, if you delete rows from table, this does not decrease the TT bytes that snowflake needs to carry forward.
7. Remmeber, the TT data and fail safe data may continue to exist after the table has been dropped and
   this is because it needs to honour the ability to query historical data for last TT period  and 
   the ability to recover table from last 7 days of data.


Q. What are time-travel bytes ?
================================
1. This is the amount of data that snowflake is storing as backup at any point of time.
2. This amount will vary from time to time.


Understanding Fail-safe
=======================
1. Fail-safe provides a (non-configurable) 7-day period during which historical data may be recoverable by Snowflake.

2. This period starts immediately after the Time Travel retention period ends. 

3. Note, however, that a long-running Time Travel query will delay moving any data and objects (tables, schemas, and databases)
    in the account into Fail-safe, until the query completes.

Attention
=========

1. Fail-safe is a data recovery service that is provided on a best effort basis and is intended only for use when all other recovery options have been attempted.

2. Fail-safe is not provided as a means for accessing historical data after the Time Travel retention period has ended.
   It is for use only by Snowflake to recover data that may have been lost or damaged due to extreme operational failures.

3. Data recovery through Fail-safe may take from several hours to several days to complete.



Data retention period
=====================
1. A key component of Snowflake Time Travel is the data retention period.

2. When data in a table is modified, including deletion of data or dropping an object containing data, Snowflake preserves the state of the data before the update. 

3. The data retention period specifies the number of days for which this historical data is preserved and, therefore, Time Travel operations
    (SELECT, CREATE … CLONE, UNDROP) can be performed on the data.

4. The standard retention period is 1 day (24 hours) and is automatically enabled for all Snowflake accounts:

              - For Snowflake Standard Edition, the retention period can be set to 0 (or unset back to the default of 1 day)
                    at the account and object level (i.e. databases, schemas, and tables).

              - For Snowflake Enterprise Edition (and higher):
                      For transient databases, schemas, and tables, the retention period can be set to 0 (or unset back to the default of 1 day). 
                          The same is also true for temporary tables.

                      For permanent databases, schemas, and tables, the retention period can be set to any value from 0 up to 90 days.
Note
====
1. A retention period of 0 days for an object effectively deactivates Time Travel for the object.

2. When the retention period ends for an object, the historical data is moved into Snowflake Fail-safe:

          - Historical data is no longer available for querying.

          - Past objects can no longer be cloned.

          - Past objects that were dropped can no longer be restored.

3. To specify the data retention period for Time Travel:

   The DATA_RETENTION_TIME_IN_DAYS object parameter can be used by users with the ACCOUNTADMIN role to set the default retention period for your account.

4. The same parameter can be used to explicitly override the default when creating a database, schema, and individual table.

5. The data retention period for a database, schema, or table can be changed at any time.

6. The MIN_DATA_RETENTION_TIME_IN_DAYS account parameter can be set by users with the ACCOUNTADMIN role to set a minimum retention period for the account. 

7. This parameter does not alter or replace the DATA_RETENTION_TIME_IN_DAYS parameter value. However it may change the effective data retention time. 
   When this parameter is set at the account level, the effective minimum data retention period for an object is determined by
    MAX(DATA_RETENTION_TIME_IN_DAYS, MIN_DATA_RETENTION_TIME_IN_DAYS).


EOF
#
clear
echo -n "View time travel and failsafe primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
#
########################################################################################
# Name     : list_all_tables
# Overview : The function lists all tables.
#
# Notes    : 1. The function generates the following dynamic script that can be
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
list_all_tables()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
# 
cat <<EOF2  > ${SQL_SCRIPT} 
!set echo=True;

SELECT  table_catalog,
        table_schema,
        substr(table_name,1,30) table_name,
        -- table_owner table_creation_role,
        -- owner_role_type,
        table_type,
        to_char(created,'DD-MON-YYYY') created,
        last_ddl_by table_owner,
        retention_time,
        row_count,
        bytes
-- from snowflake.account_usage.tables
from scratch.information_schema.tables
--
-- account_usage only
-- where              
---deleted is null and
--table_catalog != 'SNOWFLAKE'
--
order by 1,2,3 ;

EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "                  List of All Tables"> ${REPORT_FILE}
echo "                  ===================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#                                       
#
########################################################################################
# Name     : list_tables_with_tt_and_fs_days
# Overview : The function lists all tables with time travel and fail safe days.
#
# Notes    : 1. The function generates the following dynamic script that can be
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
list_tables_with_tt_and_fs_days()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
# 
cat <<EOF2  > ${SQL_SCRIPT} 
!set echo=True;

SELECT m.table_catalog,
       m.table_schema,
       substr(m.table_name,1,20) table_name,
       t.table_type,
       --- m.table_created,
       to_char(m.table_dropped,'DD-MON-YYYY') as Dropped,
       t.last_ddl_by table_owner,
       -- substr(to_char(t.retention_time),8)  as RTD,
       t.row_count ,
       t.retention_time,
       m.active_bytes ,
       m.time_travel_bytes tt_bytes,
       m.failsafe_bytes ff_bytes
FROM snowflake.account_usage.table_storage_metrics  m,
     snowflake.account_usage.tables t
WHERE  m.id = t.table_id         and
      (
         m.time_travel_bytes > 0  
               or
         m.failsafe_bytes > 0  
                    
      )
ORDER BY 1,2,3 ;

EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "              List of Tables With Time Travel and FailSafe Days"> ${REPORT_FILE}
echo "              ==================================================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
########################################################################################
# Name     : create_table
# Overview : The function is used to create table.
#
# Notes    : 1. The function generates the following dynamic script that can be
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
create_table ()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#  
# Full Syntax
# 
# CREATE [ OR REPLACE ]
#     [ { [ { LOCAL | GLOBAL } ] TEMP | TEMPORARY | VOLATILE | TRANSIENT } ]
#   TABLE [ IF NOT EXISTS ] <table_name> (
#     -- Column definition
#     <col_name> <col_type>
#       [ inlineConstraint ]
#       [ NOT NULL ]
#       [ COLLATE '<collation_specification>' ]
#       [
#         {
#           DEFAULT <expr>
#           | { AUTOINCREMENT | IDENTITY }
#             [
#               {
#                 ( <start_num> , <step_num> )
#                 | START <num> INCREMENT <num>
#               }
#             ]
#             [ { ORDER | NOORDER } ]
#         }
#       ]
#       [ [ WITH ] MASKING POLICY <policy_name> [ USING ( <col_name> , <cond_col1> , ... ) ] ]
#       [ [ WITH ] PROJECTION POLICY <policy_name> ]
#       [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
#       [ COMMENT '<string_literal>' ]
# 
#     -- Additional column definitions
#     [ , <col_name> <col_type> [ ... ] ]
# 
#     -- Out-of-line constraints
#     [ , outoflineConstraint [ ... ] ]
#   )
#   [ CLUSTER BY ( <expr> [ , <expr> , ... ] ) ]
#   [ ENABLE_SCHEMA_EVOLUTION = { TRUE | FALSE } ]
#   [ DATA_RETENTION_TIME_IN_DAYS = <integer> ]
#   [ MAX_DATA_EXTENSION_TIME_IN_DAYS = <integer> ]
#   [ CHANGE_TRACKING = { TRUE | FALSE } ]
#   [ DEFAULT_DDL_COLLATION = '<collation_specification>' ]
#   [ COPY GRANTS ]
#   [ COMMENT = '<string_literal>' ]
#   [ [ WITH ] ROW ACCESS POLICY <policy_name> ON ( <col_name> [ , <col_name> ... ] ) ]
#   [ [ WITH ] AGGREGATION POLICY <policy_name> [ ENTITY KEY ( <col_name> [ , <col_name> ... ] ) ] ]
#   [ [ WITH ] JOIN POLICY <policy_name> [ ALLOWED JOIN KEYS ( <col_name> [ , ... ] ) ] ]
#   [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
# Where:
# inlineConstraint ::=
#   [ CONSTRAINT <constraint_name> ]
#   { UNIQUE
#     | PRIMARY KEY
#     | [ FOREIGN KEY ] REFERENCES <ref_table_name> [ ( <ref_col_name> ) ]
#   }
#   [ <constraint_properties> ]
# For additional inline constraint details, see CREATE | ALTER TABLE … CONSTRAINT.
# outoflineConstraint ::=
#   [ CONSTRAINT <constraint_name> ]
#   { UNIQUE [ ( <col_name> [ , <col_name> , ... ] ) ]
#     | PRIMARY KEY [ ( <col_name> [ , <col_name> , ... ] ) ]
#     | [ FOREIGN KEY ] [ ( <col_name> [ , <col_name> , ... ] ) ]
#       REFERENCES <ref_table_name> [ ( <ref_col_name> [ , <ref_col_name> , ... ] ) ]
#   }
#   [ <constraint_properties> ]
#   [ COMMENT '<string_literal>' ]
# For additional out-of-line constraint details, see CREATE | ALTER TABLE … CONSTRAINT.
# Note
# ====
# 1. Do not specify copy options using the CREATE STAGE, ALTER STAGE, CREATE TABLE, or ALTER TABLE commands.
# 2. We recommend that you use the COPY INTO <table> command to specify copy options.
# 
# 
cat <<EOF2  > ${SQL_SCRIPT} 
!set echo=True;

--
--  create table TT_TEST_01 (  id number(2));
--
-- query information schema for TT for live tables
--
--
SELECT table_catalog,
       table_schema,
       table_name,
       last_ddl_by as table_owner,
       row_count,
       retention_time
FROM scratch.information_schema.tables 
WHERE table_name = 'TT_TEST_01';
--
-- query information schema for TT for live tables
--
SELECT table_catalog,
       table_schema,
       table_name,
       table_dropped,
       table_entered_failsafe,
       time_travel_bytes ,
      failsafe_bytes
FROM scratch.information_schema.table_storage_metrics
WHERE table_name = 'TT_TEST_01';
--
--
EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "              New Table Details"> ${REPORT_FILE}
echo "              =================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
#
##############################################################################################################
# Name     : show_table_design
# Overview : The function shows table design
# Notes    :
##############################################################################################################
show_table_design()
{

cat <<EOF  > ${TEMP_FILE_1}

Table Design Considerations
============================
1. Choosing table type
2. Date/Time Data Types for Columns
3. Referential Integrity Constraints
4. When to Set a Clustering Key
5. When to Specify Column Lengths
6. Storing Semi-structured Data in a VARIANT Column vs. Flattening the Nested Structure


Date/Time Data Types for Columns
================================
When defining columns to contain dates or timestamps, Snowflake recommends choosing a date or timestamp data type rather than a character data type. Snowflake stores DATE and TIMESTAMP data more efficiently than VARCHAR, resulting in better query performance. Choose an appropriate date or timestamp data type, depending on the level of granularity required.

Referential Integrity Constraints
==================================
When they are created on standard tables, referential integrity constraints, as defined by primary-key/foreign-key relationships, are informational; they are not enforced. NOT NULL constraints are enforced, but other constraints are not. However, constraints on hybrid tables are enforced; see Overview of Constraints.

In general, constraints provide valuable metadata. Primary and foreign keys enable your project team to understand the schema design and see the relationships between the tables and their columns.

Additionally, most business intelligence (BI) and visualization tools import the foreign key definitions with the tables and build the proper join conditions. This approach saves time and is potentially less prone to error than someone having to guess how to join the tables and manually configure the tool. Basing joins on primary and foreign keys also brings integrity to the design, because the joins are not left to different developers to interpret. Some BI and visualization tools also take advantage of constraint information to rewrite queries more efficiently, for example, by using join elimination.

Specify a constraint when creating or modifying a table using the CREATE | ALTER TABLE … CONSTRAINT commands.

In the following example, the CREATE TABLE statement for the second table (salesorders) defines an out-of-line foreign key constraint that references a column in the first table (salespeople):

SQL
Python
CREATE OR REPLACE TABLE salespeople (
  sp_id INT NOT NULL UNIQUE,
  name VARCHAR DEFAULT NULL,
  region VARCHAR,
  constraint pk_sp_id PRIMARY KEY (sp_id)
);
CREATE OR REPLACE TABLE salesorders (
  order_id INT NOT NULL UNIQUE,
  quantity INT DEFAULT NULL,
  description VARCHAR,
  sp_id INT NOT NULL UNIQUE,
  constraint pk_order_id PRIMARY KEY (order_id),
  constraint fk_sp_id FOREIGN KEY (sp_id) REFERENCES salespeople(sp_id)
);
Query the GET_DDL function to retrieve a DDL statement that could be executed to recreate the specified table. The statement includes the constraints currently set on a table.

For example:

SELECT GET_DDL('TABLE', 'mydb.public.salesorders');
+-----------------------------------------------------------------------------------------------------+
| GET_DDL('TABLE', 'MYDATABASE.PUBLIC.SALESORDERS')                                                   |
|-----------------------------------------------------------------------------------------------------|
| create or replace TABLE SALESORDERS (                                                               |
|   ORDER_ID NUMBER(38,0) NOT NULL,                                                                   |
|   QUANTITY NUMBER(38,0),                                                                            |
|   DESCRIPTION VARCHAR(16777216),                                                                    |
|   SP_ID NUMBER(38,0) NOT NULL,                                                                      |
|   unique (SP_ID),                                                                                   |
|   constraint PK_ORDER_ID primary key (ORDER_ID),                                                    |
|   constraint FK_SP_ID foreign key (SP_ID) references MYDATABASE.PUBLIC.SALESPEOPLE(SP_ID)           |
| );                                                                                                  |
+-----------------------------------------------------------------------------------------------------+
Alternatively, retrieve a list of all table constraints by schema (or across all schemas in a database) by querying the TABLE_CONSTRAINTS view in the Information Schema.

For example:

SELECT table_name, constraint_type, constraint_name
  FROM mydb.INFORMATION_SCHEMA.TABLE_CONSTRAINTS
  WHERE constraint_schema = 'PUBLIC'
  ORDER BY table_name;
+-------------+-----------------+-----------------------------------------------------+
| TABLE_NAME  | CONSTRAINT_TYPE | CONSTRAINT_NAME                                     |
|-------------+-----------------+-----------------------------------------------------|
| SALESORDERS | UNIQUE          | SYS_CONSTRAINT_fce2257e-c343-4e66-9bea-fc1c041b00a6 |
| SALESORDERS | FOREIGN KEY     | FK_SP_ID                                            |
| SALESORDERS | PRIMARY KEY     | PK_ORDER_ID                                         |
| SALESORDERS | UNIQUE          | SYS_CONSTRAINT_bf90e2b3-fd4a-4764-9576-88fb487fe989 |
| SALESPEOPLE | PRIMARY KEY     | PK_SP_ID                                            |
+-------------+-----------------+-----------------------------------------------------+

When to Set a Clustering Key
============================

Specifying a clustering key is not necessary for most tables. Snowflake performs automatic tuning via the optimization engine and micro-partitioning. In many cases, data is loaded and organized into micro-partitions by date or timestamp, and is queried along the same dimension.

When should you specify a clustering key for a table? First, note that clustering a small table typically doesn’t improve query performance significantly.

For larger data sets, you might consider specifying a clustering key for a table when:

The order in which the data is loaded does not match the dimension by which it is most commonly queried (e.g. the data is loaded by date, but reports filter the data by ID). If your existing scripts or reports query the data by both date and ID (and potentially a third or fourth column), you may see some performance improvement by creating a multi-column clustering key.

Query Profile indicates that a significant percentage of the total duration time for typical queries against the table is spent scanning. This applies to queries that filter on one or more specific columns.

Note that reclustering rewrites existing data with a different order. The previous ordering is stored for 7 days to provide Fail-safe protection. Reclustering a table incurs compute costs that correlate to the size of the data that is reordered.

For more information, see Automatic Clustering.

When to Specify Column Lengths
==============================


Snowflake compresses column data effectively; therefore, creating columns larger than necessary has minimal impact on the size of data tables. Likewise, there is no query performance difference between a column with a maximum length declaration (e.g. VARCHAR(16777216)), and a smaller precision.

However, when the size of your column data is predictable, Snowflake recommends defining an appropriate column length, for the following reasons:

Data loading operations are more likely to detect issues such as columns loaded out of order, e.g. a 50-character string loaded erroneously into a VARCHAR(10) column. Such issues produce errors.

When the column length is unspecified, some third-party tools may anticipate consuming the maximum size value, which can translate into increased client-side memory usage or unusual behavior.

Storing Semi-structured Data in a VARIANT Column vs. Flattening the Nested Structure
=====================================================================================

If you are not sure yet what types of operations you want perform on your semi-structured data, Snowflake recommends storing the data in a VARIANT column for now. For data that is mostly regular and uses only native types (strings and integers), the storage requirements and query performance for operations on relational data and data in a VARIANT column is very similar.

For better pruning and less storage consumption, Snowflake recommends flattening your object and key data into separate relational columns if your semi-structured data includes:

Dates and timestamps, especially non-ISO 8601 dates and timestamps, as string values

Numbers within strings

Arrays

Non-native values such as dates and timestamps are stored as strings when loaded into a VARIANT column, so operations on these values could be slower and also consume more space than when stored in a relational column with the corresponding data type.

If you know your use cases for the data, perform tests on a typical data set. Load the data set into a VARIANT column in a table. Use the FLATTEN function to extract the objects and keys you plan to query into a separate table. Run a typical set of queries against both tables to see which structure provides the best performance.

Converting a Permanent Table to a Transient Table or Vice-Versa
================================================================

Currently, it is not possible to change a permanent table to a transient table using the ALTER TABLE command. The TRANSIENT property is set at table creation and cannot be modified.

Similarly, it is not possible to directly change a transient table to a permanent table.

To convert an existing permanent table to a transient table (or vice versa) while preserving data and other characteristics such as column defaults and granted privileges, you can create a new table using one of the interfaces as described in the following examples:

SQL
Python
Use the COPY GRANTS clause of the CREATE TABLE command:

CREATE TRANSIENT TABLE my_new_table LIKE my_old_table COPY GRANTS;
Then use the INSERT command to copy the data:

INSERT INTO my_new_table SELECT * FROM my_old_table;
If you want to preserve all of the data, but not the granted privileges and other characteristics, you can use one of the following interfaces:

SQL
Python
Use a CREATE TABLE AS SELECT (CTAS) statement:

CREATE TRANSIENT TABLE my_transient_table AS SELECT * FROM mytable;
Another way to make a copy of a table (but change the lifecycle from permanent to transient) is to clone the table using one of the following interfaces:

SQL
Python
Use the CLONE clause of the CREATE TABLE command:

CREATE TRANSIENT TABLE foo CLONE bar COPY GRANTS;
Copy
Old partitions are not affected (they do not become transient), but new partitions added to the clone will follow the transient lifecycle.

You cannot clone a transient table to a permanent table.

EOF
#
clear
echo -n "View table design primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
#
}
#
#
#
#
########################################################################################
# Name     : display_table_management_menu
# Overview : The function displays table management menu.
# Notes :
#########################################################################################
display_table_management_menu()
{
#                                               
MENU_NAME=tabm

while true
do
clear
echo  "
##############################################
#         Table Management Menu              #
#                                            #
#  5. Time Travel and Failsafe Primer        #
# 10. List All Tables                        #
# 15  List Tables With TT and FS Days        #
# 20  Create Table                           #
# 25  Table Design Primer                    #
#                                            #
# 98. Root Menu                              #
# 99. Exit                                   #
#                                            #
#TT=Time Travel FS=Fail Safe                 # 
##############################################"
echo  -n "Enter Option-->"
read MENU_OPTION
process_menu_option

done
#                                                   
#
}
#
#
#
#
########################################################################################
# Name     : sraging_primer
# Overview : The function gives a primer on staging and stages.
# Notes :
#########################################################################################
staging_primer ()
{
cat <<EOF > ${TEMP_FILE_1}

            Staging and Stages Primer
            =========================

Q. What is staging ?
====================
1. It's the process that loads data into an area caled stage within snowflake.
2. Data is loaded into snowflake tables from a staging area.

Q. What is a stage ?
=====================
1. A stage is a designated area withing snowflake database, which is used to load data into tables.


Q. What are the different types of stages ?
===========================================
1. There are two types of stages:
     - internal stage
     - external stage

2. Internal stage has following stages;

        -  User stage
        -  Table stage
        -  Named stage


                      User Stage
                      ==========

Q. What is an user stage ?
==========================
1. It's an internal stage.

2. It's the dedicated staging area attached to every snowflake account.

Q. What are the characteristics of a user stage ?
=================================================
 
 
                      Table Stage
                      ===========

Q. What is a table stage ?
=========================
1. It's an internal stage.

2. It's the dedicated staging area attached to every table.


Q. What are the characteristics of a table stage ?
==================================================
1. A table stage has the same name as the table.
   For example, a table named mytable has a stage referenced as @%mytable.

2. A TABLE STAGE IS AN IMPLICIT STAGE TIED TO A TABLE OBJECT.
   It’s not a separate database object.
   As a result, a table stage has no grantable privileges of its own.
   A table stage is also not appropriate if you need to copy file data into multiple tables.

3. To stage files on a table stage, list the files, query the files, or drop them, you must be the table owner (have the role 
   with the OWNERSHIP privilege on the table).

4. Unlike a named stage, you can’t alter or drop a table stage.

5. Table stages don’t support transforming data while loading it (using a query as the source for the COPY command).

 
                      Named Stage
                      ===========

Q. What is a named stage ?
==========================
1. It's an interl stage.
2. This does not exist unless created explicitly.
2. 

Q. What are the characteristics of a named stage ?
==================================================
 
1. A named internal stage is a database objects that can stage any files.

2. Named stages are database objects that provide the greatest degree of flexibility for data loading:

3. Users with the appropriate privileges on the stage can load data into any table.

4. Because the stage is a database object, the security/access rules that apply to all objects apply.
   The privileges to use a stage can be granted or revoked from roles. In addition, ownership of the stage can be transferred to another role.

5. If you plan to stage data files that will be loaded only by you, or will be loaded only into a single table, then you may prefer to simply use
   either your user stage or the stage for the table into which you will be loading data.

6. Named stages are optional but recommended when you plan regular data loads that could involve multiple users and/or tables. 


                      External Stage
                      =============

Q. What is an external stage ?
==============================
1. It's an external stage as the name suggests
2. It is created to facilitate data loading into cloud storage.

Q. What are the properties of an external stage ?
=================================================
1. It must refers to a cloud storage
2. It  is used to support an external table
3. Data can not be copied into an external stage using copy ; external stage is read only
4. Data can be copied from external stage into table
5. When copying data into table, column number in file must match that of table
6. Data can be inserted into table using select from external stage
7. A file format can be associated with it 
8. Data can be queried using $ notation
9. Data can be retrieved in random order ( eg. $2, $5,$1 )
10 Alias can be used with $ notation
11. select * can not be used.
12. It is possible to intergrate different cloud storage using external stage.
 

#
#
EOF
#
echo -n " View staging primer; press any key to continue..."
read DUMMY
view  ${TEMP_FILE_1} 
#
}
#
#
########################################################################################
# Name     : data_loading_unloading_primer
# Overview : The function gives a primer on data loading.
# Notes :
#########################################################################################
data_loading_unloading_primer ()
{
cat <<EOF > ${TEMP_FILE_1}

                               Data Loading Primer
                               ===================

Q. How data is loaded into snowflake ?
=======================================
1. Data loading into snowflake is a two-stage process.

Q. What are the two processes  required to load data into snowglake ?
=====================================================================
1. Load data into staging area using PUT command 
2. Copy data from staging  into tables using COPY or SELECT command

Q. What is the full syntax of PUT comammd ?
===========================================

PUT file://<absolute_path_to_file>/<filename> internalStage
   [ PARALLEL = <integer> ]
   [ AUTO_COMPRESS = TRUE | FALSE ]
   [ SOURCE_COMPRESSION = AUTO_DETECT | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE ]
   [ OVERWRITE = TRUE | FALSE ]
#
#
#
Q. What is the full syntax of COPY comammd ?
===========================================
/* Standard data load */
COPY INTO [<namespace>.]<table_name>
     FROM { internalStage | externalStage | externalLocation }
[ FILES = ( '<file_name>' [ , '<file_name>' ] [ , ... ] ) ]
[ PATTERN = '<regex_pattern>' ]
[ FILE_FORMAT = ( { FORMAT_NAME = '[<namespace>.]<file_format_name>' |
                    TYPE = { CSV | JSON | AVRO | ORC | PARQUET | XML } [ formatTypeOptions ] } ) ]
[ copyOptions ]
[ VALIDATION_MODE = RETURN_<n>_ROWS | RETURN_ERRORS | RETURN_ALL_ERRORS ]


Q. What are the data format types supported by  COPY comamnd ?
==============================================================

formatTypeOptions ::=
-- If FILE_FORMAT = ( TYPE = CSV ... )

     COMPRESSION = AUTO | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE
     RECORD_DELIMITER = '<string>' | NONE
     FIELD_DELIMITER = '<string>' | NONE
     MULTI_LINE = TRUE | FALSE
     PARSE_HEADER = TRUE | FALSE
     SKIP_HEADER = <integer>
     SKIP_BLANK_LINES = TRUE | FALSE
     DATE_FORMAT = '<string>' | AUTO
     TIME_FORMAT = '<string>' | AUTO
     TIMESTAMP_FORMAT = '<string>' | AUTO
     BINARY_FORMAT = HEX | BASE64 | UTF8
     ESCAPE = '<character>' | NONE
     ESCAPE_UNENCLOSED_FIELD = '<character>' | NONE
     TRIM_SPACE = TRUE | FALSE
     FIELD_OPTIONALLY_ENCLOSED_BY = '<character>' | NONE
     NULL_IF = ( [ '<string>' [ , '<string>' ... ] ] )
     ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     EMPTY_FIELD_AS_NULL = TRUE | FALSE
     SKIP_BYTE_ORDER_MARK = TRUE | FALSE
     ENCODING = '<string>' | UTF8


-- If FILE_FORMAT = ( TYPE = JSON ... )

     COMPRESSION = AUTO | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE
     DATE_FORMAT = '<string>' | AUTO
     TIME_FORMAT = '<string>' | AUTO
     TIMESTAMP_FORMAT = '<string>' | AUTO
     BINARY_FORMAT = HEX | BASE64 | UTF8
     TRIM_SPACE = TRUE | FALSE
     MULTI_LINE = TRUE | FALSE
     NULL_IF = ( [ '<string>' [ , '<string>' ... ] ] )
     ENABLE_OCTAL = TRUE | FALSE
     ALLOW_DUPLICATE = TRUE | FALSE
     STRIP_OUTER_ARRAY = TRUE | FALSE
     STRIP_NULL_VALUES = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     IGNORE_UTF8_ERRORS = TRUE | FALSE
     SKIP_BYTE_ORDER_MARK = TRUE | FALSE

-- If FILE_FORMAT = ( TYPE = AVRO ... )

     COMPRESSION = AUTO | GZIP | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE
     TRIM_SPACE = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     NULL_IF = ( [ '<string>' [ , '<string>' ... ] ] )

-- If FILE_FORMAT = ( TYPE = ORC ... )

     TRIM_SPACE = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     NULL_IF = ( [ '<string>' [ , '<string>' ... ] ] )

-- If FILE_FORMAT = ( TYPE = PARQUET ... )

     COMPRESSION = AUTO | SNAPPY | NONE
     BINARY_AS_TEXT = TRUE | FALSE
     USE_LOGICAL_TYPE = TRUE | FALSE
     TRIM_SPACE = TRUE | FALSE
     USE_VECTORIZED_SCANNER = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     NULL_IF = ( [ '<string>' [ , '<string>' ... ] ] )

-- If FILE_FORMAT = ( TYPE = XML ... )

     COMPRESSION = AUTO | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE
     IGNORE_UTF8_ERRORS = TRUE | FALSE
     PRESERVE_SPACE = TRUE | FALSE
     STRIP_OUTER_ELEMENT = TRUE | FALSE
     DISABLE_SNOWFLAKE_DATA = TRUE | FALSE
     DISABLE_AUTO_CONVERT = TRUE | FALSE
     REPLACE_INVALID_CHARACTERS = TRUE | FALSE
     SKIP_BYTE_ORDER_MARK = TRUE | FALSE

                               Data Unloading Primer
                               ======================


Q. How data is unloaded from snowflake  table?
==============================================
1. Data is unloaded from snowflake table using COPY comamnd

2. Data is unloaded from the stage to os files using GET command


Q. What is the full syntax of COPY command ?
============================================
COPY INTO { internalStage | externalStage | externalLocation }
     FROM { [<namespace>.]<table_name> | ( <query> ) }
[ PARTITION BY <expr> ]
[ FILE_FORMAT = ( { FORMAT_NAME = '[<namespace>.]<file_format_name>' |
                    TYPE = { CSV | JSON | PARQUET } [ formatTypeOptions ] } ) ]
[ copyOptions ]
[ VALIDATION_MODE = RETURN_ROWS ]
[ HEADER ]
Where:

internalStage ::=
    @<internal named stage>/<path>
    @%<table_name>[/<path>]
    @~<user stage>/<path>]


externalStage ::=
  @[<namespace>.]<ext_stage_name>[/<path>]

externalLocation (for Amazon S3) ::=
  '<protocol>://<bucket>[/<path>]'
  [ { STORAGE_INTEGRATION = <integration_name> } | { CREDENTIALS = ( {  { AWS_KEY_ID = '<string>' AWS_SECRET_KEY = '<string>' [ AWS_TOKEN = '<string>' ] } } ) } ]
  [ ENCRYPTION = ( [ TYPE = 'AWS_CSE' ] [ MASTER_KEY = '<string>' ] |
                   [ TYPE = 'AWS_SSE_S3' ] |
                   [ TYPE = 'AWS_SSE_KMS' [ KMS_KEY_ID = '<string>' ] ] |
                   [ TYPE = 'NONE' ] ) ]


Q. What is the full syntax of GET comamd ?
===========================================
GET internalStage file://<local_directory_path>
    [ PARALLEL = <integer> ]
    [ PATTERN = '<regex_pattern>'' ]

Example
========


Unloading data from internal state to os files 
==============================================
GET @~/myfiles file:///tmp/data/;



Unloading data from a table to files in a table stage
======================================================
Unload data from the orderstiny table into the table’s stage using a folder/filename prefix (result/data_), a named file format (myformat), and gzip compression:

COPY INTO @%orderstiny/result/data
  FROM orderstiny FILE_FORMAT = (FORMAT_NAME ='myformat' COMPRESSION='GZIP');


Unloading data from a query to files in a named internal stage
===============================================================

Unload the result of a query into a named internal stage (my_stage) using a folder/filename prefix (result/data_), a named file format (myformat), and gzip compression:

COPY INTO @my_stage/result/data
   FROM (SELECT * FROM orderstiny)
   file_format=(format_name='myformat' compression='gzip');

Note that the above example is functionally equivalent to the first example, except the file containing the unloaded data is stored in the stage location for my_stage rather than the table location for orderstiny.

Unloading data from a table directly to files in an external location
======================================================================
Unload all data in a table into a storage location using a named my_csv_format file format:

Amazon S3

Access the referenced S3 bucket using a referenced storage integration named myint:

COPY INTO 's3://mybucket/unload/'
  FROM mytable
  STORAGE_INTEGRATION = myint
  FILE_FORMAT = (FORMAT_NAME = my_csv_format);

Access the referenced S3 bucket using supplied credentials:

COPY INTO 's3://mybucket/unload/'
  FROM mytable
  CREDENTIALS = (AWS_KEY_ID='xxxx' AWS_SECRET_KEY='xxxxx' AWS_TOKEN='xxxxxx')
  FILE_FORMAT = (FORMAT_NAME = my_csv_format);


#
#
#
#
EOF
#
#
echo -n " View loading primer; press any key to continue..."
read DUMMY
view  ${TEMP_FILE_1} 
#
#
}
#
#
#
#
########################################################################################
# Name     : list_all_stages()
# Overview : The function lists all stages details.
# Notes :
#
#########################################################################################
list_all_stages()
{
cat <<EOF > ${SQL_SCRIPT}

SELECT stage_name, stage_catalog,stage_schema,stage_type,directory_enabled,created
FROM snowflake.account_usage.stages
WHERE deleted is null
order by 1;

EOF
#
snowsql ${CONNECT_STRING}  > ${TEMP_FILE_1} 2>&1

echo "                           List of All Stages"> ${REPORT_FILE}
echo "                           ==================">> ${REPORT_FILE}
cat ${TEMP_FILE_1}  >> ${REPORT_FILE}
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
}
#
#
########################################################################################
# Name     : list_files_in_all_user_stages()
# Overview : The function lists files in all user stages
# Notes    :  1.
#########################################################################################
list_files_in_all_user_stages()
{
cat <<EOF > ${SQL_SCRIPT}

SELECT file_name, stage_location,last_load_time,row_count, row_parsed
FROM snowflake.account_usage.copy_history
WHERE stage_location like 'users%'
order by 1;

EOF
#
snowsql ${CONNECT_STRING}  > ${TEMP_FILE_1} 2>&1

echo "                  List of All Files in User Stages"> ${REPORT_FILE}
echo "                  ================================">> ${REPORT_FILE}
#
cat ${TEMP_FILE_1}  >> ${REPORT_FILE}
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
}
#
#
########################################################################################
# Name     : list_files_in_current_user_stage()
# Overview : The function lists all files in current user stage
# Notes    :  
#########################################################################################
list_files_in_current_user_stage()
{
cat <<EOF > ${SQL_SCRIPT}

list @~ ;

EOF
#
snowsql ${CONNECT_STRING}  > ${TEMP_FILE_1} 2>&1

echo "                  List of All Files in Current User Stage"> ${REPORT_FILE}
echo "                  =======================================">> ${REPORT_FILE}
#
cat ${TEMP_FILE_1}  >> ${REPORT_FILE}
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
}
#
#
#
########################################################################################
# Name     : load_unload_table_using_user_stage
# Overview : The function loads data into table using  user stage and unloads data from user stage.
#
# Notes    : 1. The function generates the following dynamic script that is
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
load_unload_table_using_user_stage()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#prepare a data file called contact.csv
#
cat <<EOF > ${DATA_FILE_1}
Arif,Zaman,M,12061957,Arif.Zaman@hotmail.co.uk,07836543200
James,Bond,M,12061965,James.Bond@hotmail.co.uk,07836543100
EOF
#
# remove existing files from user stage
# load  the file with overwrite set to TRUE
# list stage files
# create table
# load table
# describe table
# query data
# 
cat <<EOF2  > ${SQL_SCRIPT} 
!set echo=True;
--
remove  @~/ ;
--
/*
PUT file://<absolute_path_to_file>/<filename> internalStage
   [ PARALLEL = <integer> ]
   [ AUTO_COMPRESS = TRUE | FALSE ]
   [ SOURCE_COMPRESSION = AUTO_DETECT | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE ]
   [ OVERWRITE = TRUE | FALSE ]
*/
put file://${DATA_FILE_1}  @~/csv 
    OVERWRITE = TRUE;
--
list @~ ;
--
create or replace table contacts ( fname varchar(15), lname varchar(30), gender varchar(1),
                                   dob varchar(8),email varchar(50),mobile varchar(11));

--
copy into contacts from   @~/csv ;
--
desc table  contacts;
--
SELECT *
FROM contacts;
--
EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "                  Result of Data Load Using User Stage"> ${REPORT_FILE}
echo "                  ===================================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
#
#unload data
#
cat <<EOF3  > ${TEMP_FILE_1} 

!set echo=True;
--
-- file must be loaded into a directory
--
get  @~/csv   file://${TEMP_DIR};
--
--
EOF3
#
#remove previous data file
##
rm ${DATA_FILE_1} 
#
# copy temp file to sql script file
# 
# clear
cp ${TEMP_FILE_1}  ${SQL_SCRIPT}

clear
echo -n "Unloading data..."
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "                  Result of Unloading Data from User Stage"> ${REPORT_FILE}
echo "                  ========================================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
# unzip  the downloaded file
#
cd ${TEMP_DIR}
gzip -d ${UNLOADED_FILE}
#
# copy the downloaded file
# 
cat ${DATA_FILE_1}  >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
#
#
EOF1
#
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
########################################################################################
# Name     : load_table_using_named_stage
# Overview : The function loads data into table using  named stage.
#
# Notes    : 1. The function generates the following dynamic script that is
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
load_table_using_named_stage()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#prepare a data file called contact.csv
#
cat <<EOF > ${DATA_FILE_1}
Arif,Zaman,M,12061957,Arif.Zaman@hotmail.co.uk,07836543200
James,Bond,M,12061965,James.Bond@hotmail.co.uk,07836543100
EOF
#
# create a named stage
# remove existing files from user stage
# load  the file with overwrite set to TRUE
# list stage files
# create table
# load table
# describe table
# query data
# 
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
create or replace stage ustage;
--
remove  @ustage/ ;
--
/*
PUT file://<absolute_path_to_file>/<filename> internalStage
   [ PARALLEL = <integer> ]
   [ AUTO_COMPRESS = TRUE | FALSE ]
   [ SOURCE_COMPRESSION = AUTO_DETECT | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE ]
   [ OVERWRITE = TRUE | FALSE ]
*/
put file://${DATA_FILE_1}    @ustage/csv 
    OVERWRITE = TRUE;
--
list @ustage ;
--
create or replace table contacts ( fname varchar(15), lname varchar(30), gender varchar(1),
                                   dob varchar(8),email varchar(50),mobile varchar(11));

--
copy into contacts from   @ustage/csv ;
--
desc table  contacts;
--
SELECT *
FROM contacts;
--
EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "                  Result of Data Load Using User Stage"> ${REPORT_FILE}
echo "                  ===================================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the scripty
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
########################################################################################
# Name     : load_table_using_table_stage
# Overview : The function loads data into table using  table stage.
#
# Notes    : 1. The function generates the following dynamic script that is
#               viewed, edited and executed as many times as required:
#                     - OUTER_WRAPPER_SCRIPT
#########################################################################################
load_table_using_table_stage()
{
#
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#prepare a data file called contact.csv
#
cat <<EOF > ${DATA_FILE_1}
Arif,Zaman,M,12061957,Arif.Zaman@hotmail.co.uk,07836543200
James,Bond,M,12061965,James.Bond@hotmail.co.uk,07836543100
EOF
#
# remove existing files from table stage
# load  the file with overwrite set to TRUE
# list stage files
# create table(skip this)
# delete from table
# load table
# describe table
# query data
# 
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
--
remove  @%contacts/;
--
/*
PUT file://<absolute_path_to_file>/<filename> internalStage
   [ PARALLEL = <integer> ]
   [ AUTO_COMPRESS = TRUE | FALSE ]
   [ SOURCE_COMPRESSION = AUTO_DETECT | GZIP | BZ2 | BROTLI | ZSTD | DEFLATE | RAW_DEFLATE | NONE ]
   [ OVERWRITE = TRUE | FALSE ]
*/
put file://${DATA_FILE_1}    @%contacts/csv 
    OVERWRITE = TRUE;
--
list @%contacts ;
--
--create or replace table contacts ( fname varchar(15), lname varchar(30), gender varchar(1),
--                                   dob varchar(8),email varchar(50),mobile varchar(11));
--
delete
from contacts;
--
copy into contacts from   @%contacts/csv ;
--
desc table  contacts;
--
SELECT *
FROM contacts;
--
EOF2
#
snowsql  ${CONNECT_STRING} > ${LOG_FILE} 2>&1
#

echo "                  Result of Data Load Using User Stage"> ${REPORT_FILE}
echo "                  ===================================">> ${REPORT_FILE}
#
cat ${LOG_FILE}  >> ${REPORT_FILE}
#
clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the scripty
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
########################################################################################
# Name     : display_data_loading_menu
# Overview : The function displays data loading menu
# Notes :
#########################################################################################
display_data_loading_menu()
{
#                                               
MENU_NAME=dl

while true
do
clear
echo  -n "

##############################################
#          Data Lolading Menu                #
#                                            #
#  0. Stage Primer                           #
#  1. Data Load and Unload Primer            #
#  5. List All Stages                        #
# 10. List All User Stages Files             #
# 15. List Current User Stage Files          #
# 20. Load/Unload Table Using User Stage(@~) #
# 25. Load Table Using Named     Stage (@)   #
# 30. Load Table Using Table     Stage (@%)  #
# 35. Load Table Using External  Stage       #
#                                            #
#                                            #
# 98. Root Menu                              #
# 99. Exit                                   #
#                                            # 
##############################################
"
echo -n "        Enter Option-->"
read MENU_OPTION
process_menu_option

done
#                                                   
#
}
#
#
#
########################################################################################
# Name     : comptute_cost_primer
# Overview : The function shows compute cost primer.
# Notes :
#########################################################################################
compte_cost_primer()
{
#
cat <<EOF  >  ${TEMP_FILE_1}

Q. What are the costs associated with working  in snowflak ?
============================================================ 
1. Compute cost
           - virtual warehouse  ( required when running queries )
           - serverless compute ( required when snowpipe is active  and task is running;although task can be associated with a virtual warehouse)
           - cloud services     ( when quering metadata )
 
2. Data Storage cost

          - Files staged for bulk data loading/unloading \(stored compressed or uncompressed\).
          - Database tables, including historical data for Time Travel.
          - Fail-safe for database tables.
          - Clones of database tables that reference data deleted in the table that owns the clones.

3. Data Transfe cost
           - any transfer of data from snowflake to os


Q. How is the compute cost  measured ?
=====================================
1. Using credit where 1 credit = ?$ , depending to snowflake edition
1 credit = $2.66 for standard snowflake edition


Understanding compute cost
==========================
Compute costs represent credits used for:

       -  Virtual Warehouse compute — Virtual warehouses consume credits as they execute queries, load data and perform other DML operations.
          Virtual Warehouses are user-managed, which means you can directly control credit consumption of these resources.

       -  Serverless compute — Serverless features use compute resources that are managed by Snowflake instead of using virtual warehouses.

       -  Compute pools — Compute pools provide the compute resources for Snowpark Container Services.

       -  Cloud Services compute — Cloud Services is the layer of the Snowflake architecture that performs services that tie together all the 
          different components of Snowflake to process user requests, login, query display, and more. Cloud Services compute resources are managed by Snowflake.


Virtual warehouse credit usage
==============================
1. A virtual warehouse is one or more clusters of compute resources that enable executing queries, loading data, and performing other DML operations. 

2. The web interface and other features use warehouses, such as Cross-Cloud Auto-Fulfillment or display information in dashboards.

3. Snowflake credits are used to pay for the processing time used by each virtual warehouse.

4. Snowflake credits are charged based on the number of virtual warehouses you use, how long they run, and their size.

5. Warehouses come in many sizes. In this table, the size specifies the compute resources per cluster available to the warehouse.

6. Each increase in size to the next larger warehouse approximately doubles the computing power and the number of credits billed per full hour that the warehouse runs.


Important
=========

Warehouses are only billed for credit usage while running. When a warehouse is suspended, it does not use any credits.

The credit numbers shown above are for a full hour of usage; however, credits are billed per-second, with a 60-second (i.e. 1-minute) minimum:

Each time a warehouse is started or resumed, the warehouse is billed for 1 minute’s worth of usage based on the hourly rate shown above.

Each time a warehouse is resized to a larger size, the warehouse is billed for 1 minute’s worth of usage; however, the number of credits billed are only for the additional compute resources that are provisioned. For example, resizing from Small (2 credits/hour) to Medium (4 credits/hour) results in billing charges for 1 minute’s worth of 2 additional credits.

After 1 minute, all subsequent billing is per-second as long as the warehouse runs continuously.

Suspending and then resuming a warehouse within the first minute results in multiple charges because the 1-minute minimum starts over each time a warehouse is resumed.

Resizing a warehouse from 5X-Large or 6X-Large to 4X-Large (or smaller) results in a brief period during which the warehouse is billed for both the new compute resources and the old resources while the old resources are quiesced.

For more information on warehouses in general, see Overview of warehouses and Warehouse considerations.

To learn how to view the historical cost of consuming compute resources with virtual warehouses, see Exploring compute cost.

Serverless credit usage
=======================

1. Serverless credit usage is the result of features relying on compute resources provided by Snowflake rather than user-managed virtual warehouses. 

2. These compute resources are automatically resized and scaled up or down by Snowflake as required for each workload.

3. For these serverless features, which usually require continuous and/or maintenance operations, this model is more efficient, allowing Snowflake 
   to charge based on the time spent using the resources.

4. In contrast, user-managed virtual warehouses consume credits while running, regardless of whether they are performing any work, which may cause them
   to be overutilized or sit idle.

5. Charges for serverless features are calculated based on total usage of snowflake-managed compute resources measured in compute-hours. 

6. Compute-Hours are calculated on a per second basis, rounded up to the nearest whole second.

7. The number of credits consumed per compute hour varies depending on the serverless feature.

8. To learn how many credits are consumed by a serverless feature, refer to the “Serverless Feature Credit Table” in the Snowflake Service Consumption Table.

9. Charges for the use of a serverless feature appear on your bill as an individual line item. 

10.Charges for both Snowflake-managed compute resources and Cloud Services appear as a single line item for that serverless feature.

11. To learn how to view the historical cost of using serverless compute resources, see Exploring compute cost.

Compute pool credit usage
=========================

1. Snowpark Container Services uses compute pools to run its jobs and services.

2. A compute pool is a collection of one or more virtual machine (VM) nodes. 

3. The number and type of these nodes determine how many credits the job or service consumes as it uses the compute pool.


Cloud service credit usage
==========================

1. The cloud services layer of the Snowflake architecture is a collection of services that coordinate activities across Snowflake.

2. This layer authenticates users, enforces security, performs query compilation and optimization, handles request query caching, and more. 

3. Cloud services tie together all of the different components of Snowflake, including supporting the use of virtual warehouses.

4. The cloud services layer is constructed of stateless compute resources, running across multiple availability zones and using a highly available,
   distributed metadata store for global state management. 

5. The cloud services layer runs on compute instances provisioned by Snowflake from the cloud provider.

6. Similar to virtual warehouse usage, Snowflake credits are used to pay for the usage of the cloud services.

7. Snowflake Marketplace calculates compute costs for listing auto-fulfillment to VPS regions by using VPS rates. 

8. For details on VPS rates, see Snowflake Service Consumption Table.

Understanding billing for cloud services usage
==============================================

1. Usage for cloud services is charged only if the daily consumption of cloud services exceeds 10% of the daily usage of virtual warehouses.

2. The charge is calculated daily (in the UTC time zone). This ensures that the 10% adjustment is accurately applied each day, at the credit price for that day.

Keep the following in mind:

1. Serverless compute does not factor into the 10% adjustment for cloud services.

2. The 10% adjustment for cloud services is calculated daily (in the UTC time zone) by multiplying daily warehouse usage by 10%.

3. The adjustment on the monthly usage statement is equal to the sum of these daily calculations.

4. If cloud services consumption is less than 10% of warehouse compute credits on a given day, then the adjustment for that day is equal to the 
   cloud services used by your account.

5. The daily adjustment never exceeds actual cloud services usage for that day. Thus, the total monthly adjustment may be significantly less than 10%.

For example:

Date  Compute Credits Used    Cloud Services Credits Used   Credit Adjustment for Cloud Services                    Credits Billed 
      (warehouse only)                                     (Lesser of 10% of Compute or CloudServices)     (Sum of Compute,loud Services, and Adjustment)

Nov 1      100                        20                              -10                                                110

Nov 2      120                        10                              -10                                                120

Nov 3      80                         5                               -5                                                  80

Nov 4      100                        13                              -10                                                103

Total      400                        48                             -35                                                 413


What are credits?
=================
1. Snowflake credits are used to pay for the consumption of resources on Snowflake.

2. A Snowflake credit is a unit of measure, and it is consumed only when a customer is using resources, such as when a virtual warehouse is running, 
   the cloud services layer is performing work, or serverless features are used.


EOF
#
clear
echo -n "View compute cost promer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
#
#
########################################################################################
# Name     : daily_credit_spend
# Overview : The function retrieves credits, spent on current day so far.
# Notes :
#########################################################################################
daily_credit_spend()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#query view
#
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;

SELECT '#START#'  ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date =  current_date();

SELECT '#END#'  ;

EOF2
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
echo "Daily Credits Spent" >  ${REPORT_FILE}
echo "===================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START#/+10  /#END#/-1 > /dev/null  2>&1
cat xx01 >> ${REPORT_FILE}
clear
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : week_to_date_credit_spend
# Overview : The function retrieves credits for current week.
# Notes    : 1. Week beings on Monday
#
#########################################################################################
week_to_date_credit_spend()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#query view
#
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;

SELECT '#START#'  ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() 
ORDER by usage_date asc;

SELECT '#END#'  ;

EOF2
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
echo "Week to Date Credit Spend" >  ${REPORT_FILE}
echo "=========================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START#/+11  /#END#/-1 > /dev/null  2>&1
cat xx01 >> ${REPORT_FILE}
clear
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : last_week_credit_spend
# Overview : The function retrieves credits, spent last week.
# Notes :
#########################################################################################
last_week_credit_spend()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
#query view
#
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;

SELECT '#START1#' ;

SELECT sum(credits_billed ) as Weekly_Total
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 7;

SELECT '#END1#' ;
--
SELECT '#START2#' ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                         previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 7
ORDER by usage_date  asc;

SELECT '#END2#';

EOF2
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# prepare header in report filke
# #
echo -e "Last 7 Days Daily Credit Spend"  > ${REPORT_FILE}
echo -e "==============================" >> ${REPORT_FILE}
#
#extract  weekly total
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+12  /#END1#/-1 > /dev/null   2>&1
cat xx01 > ${TEMP_FILE_1}
#
# extract daily spend
# 
csplit ${LOG_FILE} /#START2#/+13  /#END2#/-1 > /dev/null   2>&1
cat xx01     >> ${REPORT_FILE}
echo -e "\n" >> ${REPORT_FILE}
#
#
echo  "Last 7 Days Total Credit Spend" >> ${REPORT_FILE}
echo  "==============================" >> ${REPORT_FILE}
cat ${TEMP_FILE_1}                     >> ${REPORT_FILE}
#
#
clear
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
########################################################################################
# Name     : week_to_date_and_last_week_credit_spend
# Overview : The function retrieves credits for week to date and last week
# Notes    : 1. Week beings on Monday
#
#########################################################################################
week_to_date_and_last_week_credit_spend()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# #
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- week to date credit total
--
SELECT '#START1#'  ;

SELECT sum(credits_billed) Week_to_date_Total
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() ;

SELECT '#END1#'  ;
--
-- week to date credit detail
--
SELECT '#START2#'  ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() 
ORDER by usage_date asc;

SELECT '#END2#'  ;
--
-- last week's total credit spend
--
SELECT '#START3#' ;

SELECT sum(credits_billed ) as Weekly_Total
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 7;

SELECT '#END3#' ;
--
-- last week's detail credit spend
--
SELECT '#START4#' ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                         previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 7
ORDER by usage_date  asc;

SELECT '#END4#';

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Week to Date and Last Week Detail and Total Credit Spend"  > ${REPORT_FILE}
echo  "========================================================"  >> ${REPORT_FILE}

#extract data
##
echo -e  "Week to Date Total Credit  Spend" >>  ${REPORT_FILE}
echo -e  "================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+11  /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
echo "Week to Date Detail Credit  Spend" >>  ${REPORT_FILE}
echo "=================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+11  /#END2#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
echo -e "\n"     >> ${REPORT_FILE}
#
#
echo "Last Week Total Credit Spend"   >> ${REPORT_FILE}
echo "==============================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START3#/+12  /#END3#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
echo -e "\n"   >> ${REPORT_FILE}
#
echo "Last Week Detail Credit Spend" >>  ${REPORT_FILE}
echo "=============================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START4#/+13  /#END4#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : month_to_date_and_last_month_credit_spend
# Overview : The function retrieves credits for month to date and last month.
# Notes    : 
#
#########################################################################################
month_to_date_and_last_month_credit_spend ()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- month to date credit total
--
SELECT '#START1#'  ;

SELECT sum(credits_billed) Month_to_date_Total
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between last_day(current_date() - interval '1 month') + interval '1 day' and 
                          current_date();

SELECT '#END1#'  ;
--
-- mnonth to date credit detail
--
SELECT '#START2#'  ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between last_day(current_date() - interval '1 month') + interval '1 day' and 
                          current_date()
ORDER by usage_date asc;

SELECT '#END2#'  ;
--
-- last month's total credit spend
--
SELECT '#START3#' ;

SELECT sum(credits_billed ) as Last_Month_Total
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between last_day(current_date() - interval '2 month') + interval '1 day' and 
                                last_day(current_date() - interval '1 month');

SELECT '#END3#' ;
--
-- last month's detail credit spend
--
SELECT '#START4#' ;

SELECT usage_date,credits_billed
FROM snowflake.account_usage.metering_daily_history
WHERE usage_date between last_day(current_date() - interval '2 month') + interval '1 day' and 
                                last_day(current_date() - interval '1 month')
ORDER by usage_date  asc;

SELECT '#END4#';

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Month to Date and Last Month Detail and Total Credit Spend"  > ${REPORT_FILE}
echo  "=========================================================="  >> ${REPORT_FILE}
#
#extract data for each query from the log file
#
echo -e  "Month to Date Total Credit  Spend" >>  ${REPORT_FILE}
echo -e  "=================================" >> ${REPORT_FILE}
#
# month to date total
# 
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+11  /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
echo "Month to Date Detail Credit  Spend" >>  ${REPORT_FILE}
echo "==================================" >> ${REPORT_FILE}
#
# month to date detail
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+12  /#END2#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
echo -e "\n"     >> ${REPORT_FILE}
#
# 
echo "Last Month Total Credit Spend"   >> ${REPORT_FILE}
echo "=============================" >> ${REPORT_FILE}
#
# last month total
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START3#/+11  /#END3#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
echo -e "\n"   >> ${REPORT_FILE}
#
echo "Last Month Detail Credit Spend" >>  ${REPORT_FILE}
echo "==============================" >> ${REPORT_FILE}
#
#last month detail
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START4#/+13  /#END4#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
########################################################################################
# Name     : display_credit_monitor_menu
# Overview : The function displays credit monitor menu
# Notes :
#########################################################################################
display_credit_monitor_menu()
{
#                                               
MENU_NAME=crem

while true
do
clear
echo  -n "
############################################
#         Compute Cost Monitor Menu        #
#                                          #
#  5. Compute Cost Primer                  #
#  5. List All Resource Monitors           #
# 10. Current Day(so far) Spend            #
# 15. Week to Date and Last Week Spend     #
# 20. Month to Date and Last Month Spend   #
# 25. Year to Date and Last Year Spend     #
#                                          #
#                                          #
# 98. Root Menu                            #
# 99. Exit                                 #
#                                          # 
############################################
#"
echo  -n "Enter Option-->"
read MENU_OPTION
process_menu_option

done
#                                                   
#
}
#
#
#
#
################################################################################################
# Name     :data_storage_cost_primer
# Overview :The function shows data storage cost primer.
# Notes    :
################################################################################################
data_storage_cost_primer()
{
cat <<EOF  > ${TEMP_FILE_1}

1. Storage cost represents the cost of:

          - Files staged for bulk data loading/unloading \(stored compressed or uncompressed\).

          - Database tables, including historical data for Time Travel.

          - Fail-safe for database tables.

          - Clones of database tables that reference data deleted in the table that owns the clones.

2. The monthly costs for storing data in Snowflake is based on a flat rate per terabyte \(TB\).

3. The amount charged depends on your type of account \(Capacity or On Demand\) and region

Staged file costs
=================
1. Files staged for bulk data loading/unloading incur storage costs based on the size of the files. 

Database costs
==============
1. Database costs include data stored in database tables.
2. Database costs also include historical data maintained for Time Travel. 
3. Snowflake automatically compresses all data stored in tables and uses the compressed file size to calculate the total storage used for an account.


Time Travel and Fail-safe costs
===============================
1. Time Travel and Fail-safe fees are calculated for each 24-hour period \(i.e. 1 day\) from the time the data changed.
2. The number of days historical data is maintained is based on the table type and the Time Travel retention period for the table.

3. Snowflake minimizes the amount of storage required for historical data by maintaining only the information required to restore the individual table 
   rows that were updated or deleted.
   As a result, storage usage is calculated as a percentage of the table that changed.
   Full copies of tables are only maintained when tables are dropped or truncated.


Temporary and transient tables costs
====================================
1. To help manage the storage costs associated with Time Travel and Fail-safe, Snowflake provides two table types, temporary and transient.

2. Temporary and transient tables do not incur the same fees as permanent tables:

3. Transient and temporary tables contribute to the storage charges that Snowflake bills your account until explicitly dropped.

4. Data stored in these table types contributes to the overall storage charges Snowflake bills your account while they exist.

5. Temporary tables are typically used for non-permanent session specific transitory data such as ETL or other session specific data. 

6. Temporary tables only exist for the lifetime or their associated session.

7. On session end, temporary table data is purged and unrecoverable. 

8. Temporary tables are not accessible outside the specific session which created them.

9. Transient tables exist until explicitly dropped and are available to all users with appropriate privileges.

10. Transient and temporary tables can have a Time Travel retention period of either 0 or 1 day.

11. Transient and temporary tables have no Fail-safe period.

12. Transient and temporary tables can, at most, incur a one day’s worth of storage cost.

The following table illustrates the different scenarios, based on table type:

Table Type   Time Travel Retention Period \(Days\)       Fail-safe Period \(Days\) Min ,  Max Historical Data Maintained \(Days\)

Permanent    0 or 1 \(for Snowflake Standard Edition\)           7                               7 , 8

             0 to 90 \(for Snowflake Enterprise Edition\)        7                               7 , 97

Transient    0 or 1                                              0                               0 , 1

Temporary    0 or 1                                              0                               0 , 1


Using temporary and transient tables to manage storage costs
============================================================
When choosing whether to store data in permanent, temporary, or transient tables, consider the following:

Temporary tables are dropped when the session in which they were created ends. Data stored in temporary tables is not recoverable after the table is dropped.

Historical data in transient tables cannot be recovered by Snowflake after the Time Travel retention period ends. Use transient tables only for data you can replicate or reproduce independently from Snowflake.

Long-lived tables, such as fact tables, should always be defined as permanent to ensure they are fully protected by Fail-safe.

Short-lived tables \(i.e. <1 day\), such as ETL work tables, can be defined as transient to eliminate Fail-safe costs.

If downtime and the time required to reload lost data are factors, permanent tables, even with their added Fail-safe costs, may offer a better overall solution than transient tables.

Note

The default type for tables is permanent. To define a table as temporary or transient, you must explicitly specify the type during table creation.

Hybrid table costs
==================
1. If you choose to use hybrid tables for your operational and analytical workloads, consider that cost for data storage in that table type 
    is based on your consumption rates of the following:

        -  Hybrid Table Storage \(incurred primarily by the hybrid tables themselves and the indexes they contain\)
        -  Hybrid Table Requests

1. Generally, hybrid tables are more costly than standard Snowflake tables.


Cloning tables, schemas, and databases costs
============================================
1. Snowflake’s zero-copy cloning feature provides a convenient way to quickly take a “snapshot” of any table \(excluding hybrid tables\), schema,
   or database and create a derived copy of that object which initially shares the underlying storage.
   This can be extremely useful for creating instant backups that do not incur any additional costs \(until changes are made to the cloned object\).

2. However, cloning makes calculating total storage usage more complex because each clone has its own separate life-cycle. 
   This means that changes can be made to the original object or the clone independently of each other and these changes are protected through CDP.

3. For example, when a clone is created of a table, the clone utilizes no storage because it shares all the existing micro-partitions of the original table 
   at the time it was cloned; however, rows can then be added, deleted, or updated in the clone independently from the original table.
   Each change to the clone results in new micro-partitions that are owned exclusively by the clone and are protected through CDP.

4. In addition, clones can be cloned, with no limitations on the number or iterations of clones that can be created 
   \(e.g. you can create a clone of a clone of a clone, and so on\), which results in an n-level hierarchy of cloned objects, 
   each with their own portion of shared and independent storage.

Cross-Cloud Auto-Fulfillment costs
==================================
1. Cross-Cloud Auto-Fulfillment lets you provide a data product to consumers in other cloud regions without manual data replication.

2. When your data product is auto-fulfilled to another region, you incur storage and other costs. For details, see Managing Cross-Cloud Auto-Fulfillment Costs.

EOF
#
clear
echo -n "View data storage primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
################################################################################################
# Name     :data_storage_cost_metadata_views
# Overview :The function shows  list of storage cost metedata views
# Notes    :
################################################################################################
data_storage_cost_metadata_views()
{
cat <<EOF  > ${TEMP_FILE_1}

1. Snowflake provides two schemas, ORGANIZATION_USAGE and ACCOUNT_USAGE, that contain data related to usage and cost.

2. The ORGANIZATION_USAGE schema provides cost information for all of the accounts in the organization while the ACCOUNT_USAGE schema provides similar
   information for a single account.

3. Views in these schemas provide granular, analytics-ready usage data to build custom reports or dashboards.

4. Most views in the ORGANIZATION_USAGE and ACCOUNT_USAGE schemas contain the cost of storage in terms of the size of storage.

5. To view cost in currency rather than size, write queries against the USAGE_IN_CURRENCY_DAILY view. 

6. This view converts the size of storage into cost in currency using the daily price of a TB.

The following views provide usage and cost information related to storage.

View                                Description                                                                                        Schema
APPLICATION_DAILY_USAGE_HISTORY     Daily storage usage consumption for Snowflake Native Apps in an account
                                    within the last 365 days.                                                                       ACCOUNT_USAGE

DATABASE_STORAGE_USAGE_HISTORY     Daily storage in bytes for databases \(including data in Time Travel\),
                                   Fail-safe, and hybrid tables in the account/organization.                               ORGANIZATION_USAGE ACCOUNT_USAGE

HYBRID_TABLES                      Data storage in bytes for each hybrid table row in the account.                                  ACCOUNT_USAGE

LISTING_AUTO_FULFILLMENT_ DATABASE_STORAGE_DAILY Data storage in bytes for databases fulfilled to other regions 
                                                 by Cross-Cloud Auto-Fulfillment.                                                  DATA_SHARING_USAGE

LISTING_AUTO_FULFILLMENT_ USAGE_HISTORY Estimated usage associated with fulfilling data products to other regions by
                                        using Cross-Cloud Auto-Fulfillment. Refer to the SERVICE_TYPE of STORAGE.                  ORGANIZATION_USAGE

STORAGE_DAILY_HISTORY
Average daily storage for storage in bytes. Combines database storage \(DATABASE_STORAGE_USAGE_HISTORY\) and stage storage \(STAGE_STORAGE_USAGE_HISTORY\).
ORGANIZATION_USAGE

STAGE_STORAGE_USAGE_HISTORY
Average daily storage usage, in bytes, for all the Snowflake stages including named internal stages and default staging areas.
ORGANIZATION_USAGE ACCOUNT_USAGE

TABLE_STORAGE_METRICS
Storage in bytes for tables, including storage that is no longer active but continues to incur cost \(e.g. deleted tables with the Time Travel retention period\).
ACCOUNT_USAGE

USAGE_IN_CURRENCY_DAILY
Daily average storage in bytes along with the cost of that usage in the organization’s currency.
ORGANIZATION_USAGE

Note

1. The views and table functions of the Snowflake Information Schema also provide usage data related to cost.
   Though the ACCOUNT_USAGE schema is preferred, the Information Schema can be faster in some circumstances.

ORGANIZATION_USAGE.USAGE_IN_CURRENCY_DAILY view
===============================================
=
The USAGE_IN_CURRENCY_DAILY view in the ORGANIZATION_USAGE schema can be used to return the daily credit usage and usage in currency for an organization.

Columns
Column Name               Data Type                Description
ORGANIZATION_NAME         VARCHAR                  Name of the organization.

CONTRACT_NUMBER           VARCHAR                  Snowflake contract number for the organization.

ACCOUNT_NAME              VARCHAR                  Name of the account where the usage was consumed.

ACCOUNT_LOCATOR           VARCHAR                  Locator for the account where the usage was consumed.

REGION                    VARCHAR                  Name of the region where the account is located.

SERVICE_LEVEL             VARCHAR                  Service level (edition) of the Snowflake account (Standard, Enterprise, Business Critical, etc.).

USAGE_DATE                DATE                     Date (in UTC format) in which the usage took place.

USAGE_TYPE                VARCHAR                  Corresponds to the Usage Category column in a billing statement, which exists for backward
                                                   compatibility only. Use the BILLING_TYPE, RATING_TYPE, SERVICE_TYPE, and IS_ADJUSTMENT columns 
                                                   for billing reconciliation.

USAGE                     NUMBER (38,3)            Total amount of usage charged based on SERVICE_TYPE.
                                                   The unit of the USAGE depends on the RATING_TYPE. For example, when the RATING_TYPE is compute,
                                                   USAGE is measured in credits. When the RATING_TYPE is data transfer or storage, the usage is rated in terabytes.

CURRENCY                  VARCHAR                  Currency of the usage.

USAGE_IN_CURRENCY         NUMBER (38,2)            Total amount charged for the USAGE_TYPE for USAGE on the USAGE_DATE.

BALANCE_SOURCE            VARCHAR                  Source of the funds used to pay for the daily usage. The source can be one of the following:
                                                           capacity — Usage paid with credits remaining on an organization’s capacity commitment.

                                                           rollover — Usage paid with rollover credits. When an organization renews a capacity commitment,
                                                                    unused credits are added to the balance of the new contract as rollover credits.

                                                           free usage — Usage covered by the free credits provided to the organization.

                                                           overage — Usage that was paid at on-demand pricing, which occurs when an organization has exhausted 
                                                                     its capacity, rollover, and free credits.

                                                           rebate — Usage covered by the credits awarded to the organization when it shared data with another
                                                                    organization.

BILLING_TYPE             VARCHAR                           Indicates what is being charged or credited. Possible billing types include:

                                                              consumption — Usage associated with compute credits, storage costs, and data transfer costs.

                                                              rebate — Usage covered by the credits awarded to the organization when it shared data with another
                                                                       organization.

                                                              priority support — Charges for priority support services. This charge is associated with a
                                                                                 stipulation in a contract, not with an account.

                                                              vps_deployment_fee — Charges for a Virtual Private Snowflake deployment.

                                                              support_credit — Snowflake Support credited the account to reverse charges attributed to an
                                                                               issue in Snowflake.
 
RATING_TYPE              VARCHAR                           Indicates how the usage in the record is rated, or priced. Possible values include:
                                                                - compute
                                                                - data_transfer
                                                                - storage
                                                                - other

SERVICE_TYPE
VARCHAR
Type of usage. Possible service types include:

AUTOMATIC_CLUSTERING — See Automatic Clustering.

CLOUD_SERVICES — See Cloud service credit usage.

DATA_TRANSFER — See Understanding data transfer cost.

INTERNAL_DATA_TRANSFER — See costs associated with Snowpark Container Services.

LOGGING — See Logging, tracing, and metrics.

MATERIALIZED_VIEW — See Working with Materialized Views.

OUTBOUND_PRIVATELINK_DATA_PROCESSED — See Private connectivity for outbound network traffic.

OUTBOUND_PRIVATELINK_ENDPOINTS — See Private connectivity for outbound network traffic.

REPLICATION — See Introduction to replication and failover across multiple accounts.

QUERY_ACCELERATION — See Using the Query Acceleration Service

SEARCH_OPTIMIZATION — See Search Optimization Service

SERVERLESS_ALERTS — See Setting up alerts based on data in Snowflake.

SERVERLESS_TASK — See Introduction to tasks.

SNOWPIPE — See Snowpipe.

SNOWPIPE_STREAMING — See Snowpipe Streaming.

STORAGE — See Understanding storage cost.

TRUST_CENTER — See Trust Center.

WAREHOUSE_METERING — See Virtual warehouse credit usage. Does not indicate usage of serverless or cloud services compute.

IS_ADJUSTMENT
BOOLEAN
Indicates whether the record is an adjustment to usage.

Usage notes
Latency for the view may be up to 72 hours.

Until month close, data for a given day in a month can change to account for any end-of-month adjustments/credits, contract amendments, or Snowflake account transfers between organizations.

Customers who signed a contract through a Snowflake reseller cannot access data in this view.

Data is retained indefinitely.

This view does not include data generated prior to June 2020. To obtain data before this date, contact Snowflake Support.

Was this page helpful?

Yes
No
EOF
#
#
clear
echo -n "View data storage primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
########################################################################################
# Name     : week_to_date_and_last_week_cost
# Overview : The function retrieves cost for week to date and last week
# Notes    : 
#
#########################################################################################
week_to_date_and_last_week_cost()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# #
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- week to date total compute cost
-- rating_type = 'COMPUTE'
--
SELECT '#START1#'  ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() and
      rating_type  = 'COMPUTE' and
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency
UNION
--
-- week to date total storage cost
-- rating_type = 'STORAGE'
--
SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() and
      rating_type  = 'STORAGE' and
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency;

SELECT '#END1#'  ;
--
-- week to date detail  compupte cost
-- rating_type = COMPUTE
--
SELECT '#START2#'  ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() and
      rating_type  = 'COMPUTE' and
      billing_type = 'CONSUMPTION'
UNION
--
-- week to date detail  storage cost
-- rating_type = STORAGE
--
SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date() and
      rating_type  = 'STORAGE' and
      billing_type = 'CONSUMPTION'
ORDER by usage_date asc;

SELECT '#END2#'  ;
--
--
-- last week's total compute cost
--
SELECT '#START3#' ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          (previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6)
                                                and
      rating_type  = 'COMPUTE' and
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency
UNION
--
-- last week's total storage cost
--
SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          (previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6)
                                                and
      rating_type  = 'STORAGE' and
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency;

SELECT '#END3#' ;
--
-- last week's detail compute cost
--
SELECT '#START4#' ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          (previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6)
                                                and
      rating_type  = 'COMPUTE' and
      billing_type = 'CONSUMPTION'
UNION 
--
-- last week's detail storage cost
--
SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          (previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6)
                                                and
      rating_type  = 'STORAGE' and
      billing_type = 'CONSUMPTION'
ORDER BY usage_date asc;

SELECT '#END4#' ;
--
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Week to Date and Last Week Detail and Total Cost"  > ${REPORT_FILE}
echo  "================================================"  >> ${REPORT_FILE}

#extract data
##
echo -e  "Week to Date Total Compute and Storage Cost" >>  ${REPORT_FILE}
echo -e  "===========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+24 /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
echo "Week to Date Detail Cpmpute and Storage Cost" >>  ${REPORT_FILE}
echo "============================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+23  /#END2#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
echo -e "\n"     >> ${REPORT_FILE}
#
#
echo "Last Week Total Compute and Storage Cost"  >> ${REPORT_FILE}
echo "========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START3#/+29  /#END3#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
echo -e "\n"   >> ${REPORT_FILE}
#
echo "Last Week Detail Compute and Storage Cost" >>  ${REPORT_FILE}
echo "=========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START4#/+28  /#END4#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
########################################################################################
# Name     : month_to_date_and_last_month_cost
# Overview : The function retrieves cost for week to date and last week
# Notes    : 
#
#########################################################################################
month_to_date_and_last_month_cost()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# #
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- month to date total compute and storage cost
-- rating_type   = 'COMPUTE' and STORAGE
-- billinbg_type = 'CONSUMPTION'
--
SELECT '#START1#'  ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between last_day(current_date() - interval '1 month') + interval '1 day' and CURRENT_DATE() and
      rating_type in ( 'COMPUTE', 'STORAGE') and 
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency;

SELECT '#END1#'  ;
--
-- month to date detail  compupte and storage cost
--
SELECT '#START2#'  ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between last_day(current_date() - interval '1 month') + interval '1 day' and CURRENT_DATE() and
      rating_type in ( 'COMPUTE', 'STORAGE') and 
      billing_type = 'CONSUMPTION'  
ORDER BY usage_date asc;

SELECT '#END2#'  ;
--
-- last month's total compute and storage cost
--
SELECT '#START3#' ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,currency,sum(usage),sum(usage_in_currency)
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between last_day(current_date() - interval '2 month') + interval '1 day' and last_day(current_date() - interval '1 month') and
      rating_type in ( 'COMPUTE', 'STORAGE') and 
      billing_type = 'CONSUMPTION'
GROUP BY organization_name, account_name,service_level,rating_type,billing_type,service_type,currency;

SELECT '#END3#' ;
--
-- last month's detail compute and storage cost
--
SELECT '#START4#' ;

SELECT organization_name, account_name,service_level,rating_type,billing_type,service_type,usage_date,usage,currency,usage_in_currency
FROM snowflake.organization_usage.usage_in_currency_daily
WHERE usage_date between last_day(current_date() - interval '2 month') + interval '1 day' and last_day(current_date() - interval '1 month') and
      rating_type in ( 'COMPUTE', 'STORAGE') and 
      billing_type = 'CONSUMPTION'
ORDER BY usage_date asc;

SELECT '#END4#' ;
--
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Month to Date and Last Month Detail and Total Cost"  > ${REPORT_FILE}
echo  "================================================"  >> ${REPORT_FILE}

#extract data
##
echo -e  "Month to Date Total Compute and Storage Cost" >>  ${REPORT_FILE}
echo -e  "===========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+13 /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
echo "Month to Date Detail Cpmpute and Storage Cost" >>  ${REPORT_FILE}
echo "============================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+13  /#END2#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
echo -e "\n"     >> ${REPORT_FILE}
#
#
echo "Last Month Total Compute and Storage Cost"  >> ${REPORT_FILE}
echo "========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START3#/+13  /#END3#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
echo -e "\n"   >> ${REPORT_FILE}
#
echo "Last Month Detail Compute and Storage Cost" >>  ${REPORT_FILE}
echo "=========================================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START4#/+13  /#END4#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : display_cost_monitor_menu
# Overview : The function displays cost monitor  menu.
# Notes :
#########################################################################################
display_cost_monitor_menu()
{
MENU_NAME=cosm

while true
do
clear

echo  -n "
#####################################
#      Cost Monitor Menu            #
#                                   #
#   5. Cost Primer                  #
#  10. Cost Metadata Views          #
#  15. Week to Date and Last Week   #
#  20. Month to Date and Last Month #
#                                   #
#  98. Root Menu                    #
#                                   #
#  99. Exit                         # 
#                                   #
#####################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
done
#
}
#
#
########################################################################################
# Name     : data_storage_metedata_views
# Overview : The function shows metadata views for tables
# Notes    : 
#########################################################################################
data_storage_metedata_views()
{
cat <<EOF  > ${TEMP_FILE_1}

SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS view
==================================================

1. This view displays table-level storage utilization information, which is used to calculate the storage billing for each table in the account,
    including tables that have been dropped, but are still incurring storage costs.

2. In addition to table metadata, the view displays the number of storage bytes billed for each table.

3. Snowflake breaks down the bytes into the following categories:

       - Active bytes, representing data in the table that can be queried.

       - Deleted bytes that are still accruing storage charges because they have not been purged yet from the system. 
                   These bytes are classified into the following sub-categories:

       - Bytes in Time Travel (i.e. recently deleted, but still within the Time Travel retention period for the table).

       - Bytes in Fail-safe (i.e. deleted bytes that are past the Time Travel retention period, but within the Fail-safe period for the table).

       - Bytes retained for clones (i.e. deleted bytes that are no longer in Time Travel or Fail-safe, but are still retained because 
                    clones of the table reference the bytes).

4. In other words, rows are maintained in this view until the corresponding tables are no longer billed for any storage, 
    regardless of various states that the data in the tables may be in (i.e. active, Time Travel, Fail-safe, or retained for clones).

Note

1. To query this view, you must use the ACCOUNTADMIN role. The view is visible to other views and can be queried, but the queries will return no rows.

Column Name         Data Type      Description
TABLE_CATALOG       TEXT           Database that the table belongs to.

TABLE_SCHEMA        TEXT           Schema that the table belongs to.

TABLE_NAME          TEXT           Name of the table

ID                  NUMBER         Unique identifier for the table.

CLONE_GROUP_ID      NUMBER Unique identifier for the oldest clone ancestor of this table. Same as ID if the table is not a clone.

IS_TRANSIENT        TEXT ‘YES’ if table is transient or temporary, otherwise ‘NO’. Transient and temporary tables have no Fail-safe period.

ACTIVE_BYTES        NUMBER Bytes owned by (and billed to) this table that are in the active state for the table. For Iceberg table storage, active bytes aren’t billed to Iceberg tables. For more information, see Iceberg table billing.

TIME_TRAVEL_BYTES   NUMBER Bytes owned by (and billed to) this table that are in the Time Travel state for the table.

FAILSAFE_BYTES      NUMBER Bytes owned by (and billed to) this table that are in the Fail-safe state for the table.

RETAINED_FOR_CLONE_BYTES NUMBER Bytes owned by (and billed to) this table that are retained after deletion because they are referenced by one or more clones of this table.

TABLE_CREATED      TIMESTAMP_LTZ Date and time at which the table was created.

TABLE_DROPPED      TIMESTAMP_LTZ Date and time at which the table was dropped. NULL if table has not been dropped.

TABLE_ENTERED_FAILSAFE TIMESTAMP_LTZ Date and time at which the table, if dropped, entered the Fail-safe state, or NULL. In this state, the table cannot be restored using UNDROP.

CATALOG_CREATED    TIMESTAMP_LTZ Date and time at which the database containing the table was created.

CATALOG_DROPPED    TIMESTAMP_LTZ Date and time at which the database containing the table was dropped.

SCHEMA_CREATED     TIMESTAMP_LTZ Date and time at which the schema containing the table was created.

SCHEMA_DROPPED     TIMESTAMP_LTZ Date and time at which the schema containing the table was dropped.

COMMENT            TEXT Comment for the table.

Usage notes
============
1. There may be a 1-2 hour delay in updating storage related statistics for active_bytes, time_travel_bytes, failsafe_bytes, and retained_for_clone_bytes.

2. ID and CLONE_GROUP_ID:
    - ID does not change for a table throughout its lifecycle, including if the table is renamed or dropped.

   -  CLONE_GROUP_ID is the ID of the oldest ancestor of a clone, including if the table has been dropped, but is still accruing storage costs.
       For example:

         Table t2 is cloned from t1.
         Table t3 is cloned from t2.

   - All three tables list the ID for t1 as their CLONE_GROUP_ID, even if t1 is dropped and eventually purged from Snowflake.

   - If ID and CLONE_GROUP_ID are identical, the table is not a clone.

   - Storage bytes are always owned by, and therefore billed to, the table where the bytes were initially added. 
        If the table is then cloned, storage metrics for these initial bytes never transfer to the clones, even if the bytes are deleted from the source table.

3. Cloned tables share the same underlying storage (at the micro-partition level) until either the original table or cloned table is modified.
   With each change made to either table, the table takes “ownership” of the changed bytes.

4. Dropped tables are displayed in the view as long as they still incur storage costs:

        -  Dropped tables retain their active storage metrics, indicating how many bytes will be active if the table is restored.

        -  Dropped tables in the Time Travel retention period for the table can be restored using UNDROP.

        -  Dropped tables in Fail-safe (TABLE_ENTERED_FAILSAFE not NULL) will potentially display NULL values in most columns, except for:

            - ID columns  ID , CLONE_GROUP_ID
            - Bytes columns   ACTIVE_BYTES , TIME_TRAVEL_BYTES , FAILSAFE_BYTES , RETAINED_FOR_CLONE_BYTES

        - These tables cannot be restored using UNDROP.


5. When data is deleted from a table with a Time Travel retention period of 0 days, asynchronous background processes purge the active bytes or move 
   them directly into Fail-safe storage, depending on the table type. This may take a short time to complete. During that time, the TIME_TRAVEL_BYTES column 
   may contain a non-zero value even when the Time Travel retention period is 0 days.

6. FAILSAFE_BYTES denotes bytes that have passed beyond Time Travel. All such bytes are billed to the current table.

6. If multiple rows have the same value in the TABLE_NAME column, this indicates that multiple versions of the table exist.
   A version is created each time a table is dropped and a new table with the same name is created, including when a CREATE OR REPLACE TABLE command 
   is issued on an existing table.
   Note that the current version will have a NULL value for the TABLE_DROPPED column; all other versions will have a timestamp value.
   This is important to note because each version of a table incurs storage costs associated with Time Travel (and Fail-safe, if the table is permanent).

7. In some cases, active bytes might include bytes for data in a dropped column. For more information, see the usage notes for ALTER TABLE.

8. Snowflake doesn’t bill for Iceberg table storage. For more information, see Iceberg table billing.


SNOWFLAKE.ACCOUNT_USAGE.TABLES
==============================
Column Name        Data Type       Description

TABLE_ID           NUMBER          Internal, Snowflake-generated identifier for the table.

TABLE_NAME         TEXT            Name of the table.

TABLE_SCHEMA_ID    NUMBER          Internal, Snowflake-generated identifier of the schema for the table.

TABLE_SCHEMA       TEXT            Schema that the table belongs to.

TABLE_CATALOG_ID   NUMBER          Internal, Snowflake-generated identifier of the database for the table.

TABLE_CATALOG      TEXT            Database that the table belongs to.

TABLE_OWNER        TEXT            Name of the role that owns the table.

TABLE_TYPE
TEXT
Indicates the table type. Valid values are BASE TABLE, TEMPORARY TABLE, EXTERNAL TABLE, EVENT TABLE, VIEW, or MATERIALIZED VIEW.

IS_TRANSIENT
TEXT
Indicates whether the table is transient.

CLUSTERING_KEY
TEXT
Column(s) and/or expression(s) that comprise the clustering key for the table.

ROW_COUNT
NUMBER
Number of rows in the table.

BYTES
NUMBER
Number of bytes accessed by a scan of the table.

RETENTION_TIME
NUMBER
Number of days that historical data is retained for Time Travel.

SELF_REFERENCING_COLUMN_NAME
TEXT
Not applicable for Snowflake.

REFERENCE_GENERATION
TEXT
Not applicable for Snowflake.

USER_DEFINED_TYPE_CATALOG
TEXT
Not applicable for Snowflake.

USER_DEFINED_TYPE_SCHEMA
TEXT
Not applicable for Snowflake.

USER_DEFINED_TYPE_NAME
TEXT
Not applicable for Snowflake.

IS_INSERTABLE_INTO
TEXT
Not applicable for Snowflake.

IS_TYPED
TEXT
Not applicable for Snowflake.

COMMIT_ACTION
TEXT
Not applicable for Snowflake.

CREATED
TIMESTAMP_LTZ
Date and time when the table was created.

LAST_ALTERED
TIMESTAMP_LTZ
Date and time the object was last altered by a DML, DDL, or background metadata operation. See Usage Notes.

LAST_DDL
TIMESTAMP_LTZ
Timestamp of the last DDL operation performed on the table or view.

All supported table/view DDL operations update this field:

{ CREATE | ALTER | DROP | UNDROP } TABLE

{ CREATE | ALTER | DROP } VIEW

All ALTER TABLE operations update this field, including setting or unsetting a table parameter (for example, COMMENT, DATA_RETENTION_TIME, etc.) and changes to table columns (ADD / MODIFY / RENAME / DROP).

For more information, see the Usage Notes.

LAST_DDL_BY
TEXT
The current username for the user who executed the last DDL operation. If the user has been dropped, shows DROPPED_USER(<id>).

For dropped users, you can join the <id> with the USER_ID column in the USERS view.

DELETED
TIMESTAMP_LTZ
Date and time when the table was dropped.

AUTO_CLUSTERING_ON
TEXT
Status of Automatic Clustering for a table. For details, see Viewing the Automatic Clustering status for a table.

COMMENT
TEXT
Comment for the table.

OWNER_ROLE_TYPE
TEXT
The type of role that owns the object, for example ROLE. If a Snowflake Native App owns the object, the value is APPLICATION. Snowflake returns NULL if you delete the object because a deleted object does not have an owner role.

INSTANCE_ID
NUMBER
Internal/system-generated identifier for the instance which the object belongs to.

IS_ICEBERG
TEXT
Indicates whether the table is an Iceberg table. Valid values are YES or NO.

IS_DYNAMIC
TEXT
Indicates whether the table is a dynamic table. Valid values are YES or NO.

IS_HYBRID
TEXT
Indicates whether the table is a hybrid table. Valid values are YES or NO.

Usage notes
============
1. Latency for the view may be up to 90 minutes.

2. The view does not recognize the MANAGE GRANTS privilege and consequently may show less information compared to a SHOW command executed by a user who holds the MANAGE GRANTS privilege.

3. Querying the SUM(BYTES) for a table does not represent the total storage usage, because the amount does not include Time Travel and Fail-safe usage.

4. Using the value in the LAST_ALTERED column for Time Travel is not recommended and can return unexpected results for the following reaons:

            - Time Travel can only be used to query historical data modified by a DML operation.

            - The LAST_ALTERED column inludes both DML and DDL operations (see the next usage note).

            -  For DML operations, the value in the LAST_ALTERED column is the timestamp at the beginning of the statement execution rather than the time of the commit of the transaction containing this statement.

5. The LAST_ALTERED column is updated when the following operations are performed on an object:

        - DDL operations.
        - DML operations (for tables only). This column is updated even when no rows are affected by the DML statement.

        - Background maintenance operations on metadata performed by Snowflake.

6. For views and tables, use the LAST_DDL column for the last modification time for an object.

7. The value in the LAST_DDL column is updated as follows:

       - When a table or view is created, the LAST_DDL timestamp is the same as the CREATED timestamp.

       - When a table or view is dropped, the LAST_DDL timestamp is the same as the DELETED timestamp.

       - Last DDL data is not available for operations that occurred before the columns were added. The new DDL fields contain null until a DDL operation is executed.

       - For replicated databases, the LAST_DDL and LAST_DDL_BY fields are only updated for objects in the primary database.
         After failover, the LAST_DDL and LAST_DDL_BY fields are updated for DDL operations for the tables and views in the newly promoted primary database.
         These fields will remain unchanged for objects in the now secondary database.

       - For objects in secondary databases that are newly created during a refresh operation, these fields are null.

8. The LAST_ALTERED column does not necessarily indicate the last refreshed time for external tables. 
   To retrieve the last refreshed time for an auto-refreshed external table, you can use the SYSTEM$EXTERNAL_TABLE_PIPE_STATUS function, 
   which returns information such as the timestamp of the last file Snowflake has registered.

EOF
#
#
clear
echo -n "View metedata views;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
#
########################################################################################
# Name     : week_to_date_and_last_week_data_storage
# Overview : The function retrieves storage for week to date and last week
# Notes    : 
#
#########################################################################################
week_to_date_and_last_week_data_storage()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# #
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- week to date storage total
--
SELECT '#START1#'  ;

SELECT database_name,sum(average_database_bytes) database_total,sum(average_failsafe_bytes) failsafe_total,
                     sum(average_hybrid_table_storage_bytes) hybrid_total
FROM snowflake.account_usage.database_storage_usage_history
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date()
GROUP BY database_name
ORDER by database_total desc ;

SELECT '#END1#'  ;
--
-- week to date storage detail
--
SELECT '#START2#'  ;

SELECT usage_date,database_name, average_database_bytes,average_failsafe_bytes, average_hybrid_table_storage_bytes
FROM snowflake.account_usage.database_storage_usage_history
WHERE usage_date between  previous_day(current_date(), 'Monday') and current_date()
ORDER by average_database_bytes desc ;

SELECT '#END2#'  ;
--
-- last week's total storage
--
SELECT '#START3#' ;

SELECT database_name,sum(average_database_bytes) database_total,sum(average_failsafe_bytes) failsafe_total, sum(average_hybrid_table_storage_bytes) hybrid_total
FROM snowflake.account_usage.database_storage_usage_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                          previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6
GROUP BY database_name
ORDER BY database_total desc ;

SELECT '#END3#' ;
--
-- last week's detail storage
--
SELECT '#START4#' ;

SELECT usage_date,database_name,average_database_bytes,average_failsafe_bytes, average_hybrid_table_storage_bytes
FROM snowflake.account_usage.database_storage_usage_history
WHERE usage_date between previous_day( previous_day(current_date(), 'Monday'), 'Monday')
                                                and 
                         previous_day( previous_day(current_date(), 'Monday'), 'Monday')  + 6
ORDER by average_database_bytes desc ;

SELECT '#END4#';

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Week to Date and Last Week Detail and Total Storage"  > ${REPORT_FILE}
echo  "===================================================="  >> ${REPORT_FILE}

#extract data
##
echo -e  "Week to Date Total Storage" >>  ${REPORT_FILE}
echo -e  "==========================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+11  /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
echo "Week to Date Detail Storage" >>  ${REPORT_FILE}
echo "===========================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+11  /#END2#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
echo -e "\n"     >> ${REPORT_FILE}
#
#
echo "Last Week Total Storage"   >> ${REPORT_FILE}
echo "=======================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START3#/+13  /#END3#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
echo -e "\n"   >> ${REPORT_FILE}
#
echo "Last Week Detail Storage" >>  ${REPORT_FILE}
echo "========================" >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START4#/+13  /#END4#/-1 > /dev/null  2>&1
cat xx01       >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
#
########################################################################################
# Name     : top_ten_storage_tables 
# Overview : The function retrieves top ten tables comparing its storage size.
# Notes    : 
#
#########################################################################################
top_ten_storage_tables()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
-- total bytes
--
SELECT '#START1#'  ;

SELECT t.table_owner,t.table_catalog,t.table_schema,t.table_name,t.table_type, m.active_bytes +  m.time_travel_bytes + m.failsafe_bytes as total_bytes
FROM snowflake.account_usage.table_storage_metrics m,
     snowflake.account_usage.tables t
WHERE m.id =  t.table_id and
      t.deleted is null
ORDER BY total_bytes desc
LIMIT 10;

SELECT '#END1#'  ;
--
-- detail bytes
--
SELECT '#START2#'  ;

SELECT t.table_owner,t.table_catalog,t.table_schema,t.table_name,t.table_type, m.active_bytes, m.time_travel_bytes,m.failsafe_bytes 
FROM snowflake.account_usage.table_storage_metrics m,
     snowflake.account_usage.tables t
WHERE m.id =  t.table_id and
      t.deleted is null
ORDER BY m.active_bytes desc
LIMIT 10;

SELECT '#END2#'  ;

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Top Ten Table Storage"  > ${REPORT_FILE}
echo  "====================="  >> ${REPORT_FILE}
echo -e "\n"                   >> ${REPORT_FILE}
#
# extract data for total storage  from log file
#
echo  "Top Ten Total Storage"  >> ${REPORT_FILE}
echo  "====================="  >> ${REPORT_FILE}
cd /tmp
csplit ${LOG_FILE} /#START1#/+14  /#END1#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
#
# extract data for detail storage  from log file
#
echo  "Top Ten Detail Storage"  >> ${REPORT_FILE}
echo  "======================"  >> ${REPORT_FILE}
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START2#/+14  /#END2#/-1 > /dev/null  2>&1
cat xx01                >> ${REPORT_FILE}
echo -e "\n"            >> ${REPORT_FILE}
#
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : deleted_tables_with_storage
# Overview : The function lists deleted tables with time travel and failsafe storage.
# Notes :
#########################################################################################
deleted_tables_with_storage()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
!set echo=True;
--
-- timel travel  bytes
--
SELECT '#START1#'  ;

SELECT t.table_owner,t.table_catalog,t.table_schema,t.table_name,t.table_type,  m.time_travel_bytes, m.failsafe_bytes
FROM snowflake.account_usage.table_storage_metrics m,
     snowflake.account_usage.tables t
WHERE m.id =  t.table_id and
      t.deleted is not null
ORDER BY m.time_travel_bytes
LIMIT 10;

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Deleted Tables With Time Travel Storage"  >  ${REPORT_FILE}
echo  "======================================="  >> ${REPORT_FILE}
echo -e "\n"                                     >> ${REPORT_FILE}
#
# extract data from log file
#
cd ${TEMP_DIR}
csplit ${LOG_FILE} /#START1#/+14  /#END1#/-1 > /dev/null  2>&1
cat xx01         >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : display_data_storage_monitor_menu
# Overview : The function displays data storage monitor  menu.
# Notes :
#########################################################################################
display_data_storage_monitor_menu()
{
MENU_NAME=stom

while true
do
clear

echo  -n "
#####################################
#      Date Storage Menu            #
#                                   #
#  5. Data Storage Metadata Views   #
# 10. WTD and Last Week Storage     #
# 15. MTD and Last Month  Storage   #
# 20. Top Ten Storage Tables        #
# 25. Deleted Tables with Storage   #
#                                   #
#  98. Root Menu                    #
#                                   #
#  99. Exit                         # 
#                                   #
# WTD=Week to Date MTD=Month to Date#
#####################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
done
#
}
#
#
#
########################################################################################
# Name     : display_warehouse_primer
# Overview : The function displays warehouse primer.
# Notes    : 
#########################################################################################
displays_warehouse_primer()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
#
cat <<EOF  >  ${TEMP_FILE_1}

Columns Shown by Show Warehouses Command
========================================

Column                Description
name                  Name of the warehouse.
state                 Whether the warehouse is:
                          active/running (STARTED), inactive (SUSPENDED), or resizing (RESIZING).

type                  Warehouse type. STANDARD and SNOWPARK-OPTIMIZED are the only currently supported types.

size                  Size of the warehouse (X-Small, Small, Medium, Large, X-Large, etc.)

min_cluster_count     Minimum number of clusters for the (multi-cluster) warehouse (always 1 for single-cluster warehouses) (enterprise edition)

max_cluster_count     Maximum number of clusters for the (multi-cluster) warehouse (always 1 for single-cluster warehouses)(enterprise edition)

started_clusters      Number of clusters currently started. (enterprise edition)

running               Number of SQL statements that are being executed by the warehouse.

queued                Number of SQL statements that are queued for the warehouse.

is_default            Whether the warehouse is the default for the current user.

is_current            Whether the warehouse is in use for the session.
                      Only one warehouse can be in use at a time for a session.
                      To specify or change the warehouse for a session, use the USE WAREHOUSE command.

auto_suspend          Period of inactivity, in seconds, after which a running warehouse will automatically suspend and stop using credits.
                      A value of null indicates the warehouse never automatically suspends.

auto_resume           Whether the warehouse, if suspended, automatically resumes when a query is submitted to the warehouse.

available             Percentage of the warehouse compute resources that are provisioned and available.

provisioning          Percentage of the warehouse compute resources that are in the process of provisioning.

quiescing             Percentage of the warehouse compute resources that are executing SQL statements, but will be shut down once the queries complete.

other                 Percentage of the warehouse compute resources that are in a state other than available, provisioning, or quiescing.

created_on            Date and time when the warehouse was created.

resumed_on            Date and time when the warehouse was last started or restarted.

updated_on            Date and time when the warehouse was last updated, which includes changing any of the properties of the warehouse or changing the 
                      state (STARTED, SUSPENDED, RESIZING) of the warehouse.

owner                 Role that owns the warehouse.

comment               Comment for the warehouse.

enable_query_acceleration            Whether the query acceleration service is enabled for the warehouse.

query_acceleration_max_scale_factor   Maximum scale factor for the query acceleration service.

resource_monitor     ID of resource monitor explicitly assigned to the warehouse; controls the monthly credit usage for the warehouse.

actives , pendings , failed , suspended , uuid

These five columns are for internal use and will be removed in a future release.

scaling_policy       Policy that determines when additional clusters (in a multi-cluster warehouse) are automatically started and shut down.

budget               Name of the budget if the object is monitored by a budget. NULL otherwise.

owner_role_type      The type of role that owns the object, for example ROLE. If a Snowflake Native App owns the object, the value is APPLICATION.
                     Snowflake returns NULL if you delete the object because a deleted object does not have an owner role.

resource_constraint  If type is SNOWPARK-OPTIMIZED, one of:
                     MEMORY_1X, MEMORY_1X_x86, MEMORY_16X, MEMORY_16X_x86, MEMORY_64X, MEMORY_64X_x86.
                     Otherwise NULL.

EOF
#
#
clear
echo -n "View time travel and failsafe primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
#
########################################################################################
# Name     : display_credit_leakage_primer
# Overview : The function displays credit leakage primer.
# Notes    : 
#########################################################################################
display_credit_leakage_primer()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
#
cat <<EOF  >  ${TEMP_FILE_1}

Q. What is a credit leakge(CL) ?
================================
1. CL is an investigation into areas where unnecessary cost is being incurred.

Q. What is cost optimisation(CO) ?
==================================
1.It is a methodical approach to control credit usage by examining credit leakge.

Q. What are the two main types of cost ?
=======================================
1. Compute 
2. Storage

Q. What are the services that incurs  compute cost ?
====================================================
1. Compute services
2. Cloud services


Q. What are the areas in compute services that incurs cost ?
============================================================
1. Warehouse compute 
2. Automatic clustering
3. Materialized views
4. Search optimisation
5. Cross cloud replication

Q. What are the areas in cloud services that incurs cost ?
============================================================
1. Authentication and Authorisation
2. Infrastructure management ( eg. clustering and declustering )
3. Metadata management  (eg. update data retention period of a table )
4. Query parsing
5. Access control


Q. What are the services that incurrs  storage cost ?
=====================================================
1. Storage services

Q. What are the areas in storage services that incurs cost ?
===========================================================
1. Storage (  tables)
        - Active
        - Time travel
        - Fail safe
        - Clone retention
2. Stage ( internal stages)

Q. What does credit pricing depend on ?
=======================================
1. Snowflake edition
2. Cloud provider
3. Region


EOF
#
#
clear
echo -n "View time travel and failsafe primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
#
########################################################################################
# Name     : warehouse_credit_leakage_control
# Overview : The function discusses credit leakage control in warehouse.
# Notes    : 
#
#########################################################################################
warehouse_credit_leakage_control()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
--
/*


How can credit leakge occur in virtual warehosue ?
===================================================
Inappropriate values of following  warehouse parameters :
    - Auto-Supend set to false
      This will lead to warehouse running idle and incurring cost.

    - Setting auto-suspend to larger value
      This will lead to warehouse running idle and incurring cost

    - Initially suspendes set to false
      This will lead to warehouse running idle after it is created.
      Usually, there is a time gap between the time the warehose is created and 
      the first compute task.

    - carry on using compute_wh ( default warehouse created with a snowflake instance)
      This might lead to using this vW to process a smnall task

What is the recommendation to control CL in  virtual warehosue creation ?
=========================================================================
1. Always set auto suspend and auto resume parameters to TRUE.

2. Always set auto-suspend value to miminmum possible ( 60s recommended)

3. Always set initially suspended to true

4. Do not grant modify privileges to VW to developers; with this privileges 
   a VW can be altered to bigger size which may not be called for.

5. Encourge developers to produce use cases for larger warehouse requirements. 

6. Review the creation of snowpark optimized and multi-clustered warehosue since 
   these warehouse incur higher costs. 

7. While creating multi-clustred VW, consider carefull whether the warehouse should be 
   running in maxmised mode ( ie. minimum cluster no and maximum cluster number are the same)


8. Constant monitoring of warehosue particularly for any idle period. If the trend shows a
   constant idle period , you can reduce the auto-suspend parameter to make the idle period smaller.

*/
--
-- list of all warehouse details
--
/*

show warehouses;
create table warehouses  as 
SELECT  *
FROM  table ( result_scan(last_query_id()) )  ;
----
desc table warehouses;
--
*/
--
/*
desc table warehouses;
+---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
| name                | type              | kind   | null? | default | primary key | unique key | check | expression | comment | policy name | privacy domain |
|---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------|
| name                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| state               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| type                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| size                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| running             | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| queued              | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_default          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_current          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| auto_suspend        | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| auto_resume         | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| available           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| provisioning        | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| quiescing           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| other               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| created_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resumed_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| updated_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| comment             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resource_monitor    | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| actives             | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| pendings            | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| failed              | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| suspended           | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| uuid                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| budget              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner_role_type     | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resource_constraint | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
+---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
28 Row(s) produced. Time Elapsed: 0.125s
*/
--
--
SELECT "name","owner", "type", "size","auto_suspend", "auto_resume","budget", "is_default"
FROM warehouses;

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Warehouse Details"  > ${REPORT_FILE}
echo  "================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View/Edit dynamically generated script that would be run;press any key to continue..."
read DUMMY
view ${REPORT_FILE}

EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
########################################################################################
# Name     : table_credit_leakage_control
# Overview : The function discusses credit leakage control in tables
# Notes    : 
#
#########################################################################################
table_credit_leakage_control()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
--
/*

Q. How can credit leakge occur in table management ?
====================================================
1. There are following three types of tables :
      - permanent
      - transient
      - temporary

Q. What aspects must be looked at for CL ?
==========================================
1. Time travel(TT) property of permanent table  

Q. What must you be aware of when creating table ?
==================================================
1. If table type is ommitted, a permanent table is created by default 
    with data_retention_period set to 1 day (default) and fail_safe to 7 days.

Q. What aspect of TT must you be aware of ?
==========================================
1. If a time travel for a table to set to 90 days, you continue to incur storage cost even if the table is dropped
   after 10 days.

2. Once a table has been dropped that has a data_retion_period of 90 days,you can not modify this
   data retention period.

Example
=======  
     <--------------------------data_retention_period---------------> 
      ----------------> 10th day          
TABLE|------------------|------------------------------------------>90 days
                    table is dropped
                    storage size = 1GB
                        |<----------------------------------------->90 days
                              cost of 1GB storage will be incurred
                              for 80 days. 

Q. What is the recommendation ?
===============================
1. Establisg use case for a permanent table
2. Establish the minimum date retention period
3. Continue to monitor table storage

Q. How can credit leakge occur in time travel(TT) ?
===================================================
1. A permanent table is created with time travel set to 90 days. However, table is dropped after few days.
   In this scenario, time travel data storage cost will be incurred on daily basis until end of data retention period
   plus 7 days for fail safe.

Q. What is the recommendation to control CL in  TT ?
====================================================
1. Create transient database for developers in order to stop permanentt tables being created.

2. All the tables in this database will be created as transient tables with default data_retention_period set to
   1 day maxxmimum and with no fail safe.

3. Developers may even choose to disable TT altoghter for specifc tables where data loss can be tolerated.
 
4.  Transient tables will continue to persist until developer choose to drop it.

5. For production permanent tables, set data_retention_period  according to your data backup and restore strategy. 

*/
--
-- check all database for retention time and whether it's transient or not
--
SELECT database_name,type,created,is_transient,retention_time, deleted
FROM snowflake.account_usage.databases
order by 1;
--
-- list tables with data retention period and failsafe entered
-- 
SELECT substr(table_name,1,20)    table_name,
       substr(table_catalog,1,20) database_name,
       substr(table_schema,1,20)  schema_name,
       is_transient,
       -- table_type,
       -- last_ddl_by,
       -- retention_time,
       to_char(table_created,'DD-MON-YYYY') created, 
       time_travel_bytes,
       failsafe_bytes,
       table_entered_failsafe,
       deleted
FROM snowflake.account_usage.table_storage_metrics
WHERE time_travel_bytes > 0
         or
      failsafe_bytes    > 0
ORDER by 1;
#
#
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Table Time Travel and Fail Safe Details"  > ${REPORT_FILE}
echo  "======================================"  >> ${REPORT_FILE}
echo -e "\n"                                    >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View/Edit the report;press any key to continue..."
read DUMMY
view  ${REPORT_FILE}
#
EOF1
#
}
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : stage_credit_leakage_control
# Overview : The function discusses credit leakage control in stages.
# Notes    : 
#
#########################################################################################
stage_credit_leakage_control()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
--
/*

Q. Where can credit leakge occur in  stage management ?
========================================================
1. Internal user stage
2. Internal table stage
3. Internal named stage


Q. How can credit leakge occur in internal user stage management ?
==================================================================
1. A user can upload and store unlimited amount of data files in this stage.
2. There is nothing in snowflake that can control this.
3. Data file storage incur cost on daily basis

Q. What is the recommendation to control CL in internal user stage management ?
================================================================================
1. Delete any unused user account; this will in turn drop the user internal stage
2. Continue to monitor the storage for user and ask them delete files that are not required.
3. Encourge the developers to delete files from their stage, once data has been loaded into the table


Q. How can credit leakge occur in internal named stage ?
========================================================
1. Storage in this stage does not incur any cost
2. However, if data is unloaded from this stage to an external stage, this will incur data transfer cost
3. If a great number of files is unloaded to external stage, the list @<stage name> command will incur additional cost.

Q. What is the recommendation to control CL in internal user stage ?
====================================================================
1. Delete any unused named internal stage .
3. Encourge the developers to delete files from their stage, once they are done with data

Q. How can credit leakge occur in internal table stage ?
========================================================
1. A user can upload and store unlimited amount of data files in this stage.
2. There is nothing in snowflake that can control this.
3. Data file storage incur cost on daily basis

Q. What is the recommendation to control CL in internal table stage ?
=====================================================================
1. Encourge  developers to delete files from stage, once they are done with data
2. Continue to monitor and seek reasons for storing files

*/
--
-- list files in stages
--
SELECT stage_name,
       stage_catalog,
       stage_schema,
       stage_type,
       to_char(created,'DD-MON-YYYY'),
       to_char(deleted,'DD-MON-YYYY'),
       directory_enabled
FROM snowflake.account_usage.stages
WHERE deleted is null
ORDER by stage_name;
--
#
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Stage Details"  > ${REPORT_FILE}
echo  "================"  >> ${REPORT_FILE}
echo -e "\n"              >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : display_cost_optimisation_menu
# Overview : The function displays cost optimisation  menu.
# Notes :
#########################################################################################
display_cost_optimisation_menu()
{
MENU_NAME=coop
clear

while true
do
clear

echo  -n "
######################################
#    Cost Optimisation Menu          #
#                                    #
#   5. Cost Optimisation Primer   
#  10. Comnpute                      #
#      10.1  Warehouse               #
#      10.2  Automatic clustering    #
#      10.3  Materialized views      #
#      10.4  Search optimisation     #
#      10.5  Cross cloud replication #############################################################
#      10.6  Authentication and Authorisation                                                     #  
#      10.7  Infrastructure management   ( eg. clustering and declustering )                      #
#      10.8  Metadata management               (eg. update data retention period of a table )     #
#      10.9  Query parsing                                                                        #
#      10.10 Access control          ##############################################################
#                                    #
#  15. Storage ( tables)             #
#      15.1  Table (TT and FS)       #
#      15.2  Clone retention         #
#      15.3  Stage ( internal stages)#
#                                    #
#                                    #
#  98. Root Menu                     #      
#  99. Exit                          #      
#                                    #
# TT=Time Travel FS=FailSafe         #
######################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
done
}
#
#
#
########################################################################################
# Name     : show_virtual_warehouse_primer
# Overview : The function shows virtual warehouse primer.
# Notes    : 
#########################################################################################
show_virtual_warehouse_primer()
{
#
cat <<EOF  > ${TEMP_FILE_1} 
#
                                                         Virtual Warehouse Primer
                                                         ========================

Q. What is virtual warehouse  (VW)?
==================================
1. A virtual warehouse is a logical computer that performs computation .
2. It also calculate the cost for each computational task  that it performs.

Q. How does VW  calculate its cost for computation ?
===================================================
1. VW knows the amount of time a computational tesk has taken.
2. It workouts the cost of computation  interm of credit as follows:

1 credit = 3600 seconds
cost of computation in credit =  (1/3600) * computation time in second

Example
=======
computation time = 60 seconds
cost of computation in credit =  (1/3600) * 60 = .01 

Q. What is the minimmum computation time VW charges ?
=====================================================
1 second; this means that if a task takes 0.5 second, the billed computaional time will till be 1  second.

Q. Does VW have any minimum charge when resumed  and then suspended?
====================================================================
1. Yes, the minimmum is 60 seconds.

2. If a VW is resumed  and suspended within 40 seconds, VW will bill 60 second for this.


Q. How do you start a VW ?
===========================
1. A virtual warehouse is started automatically when created.
2. However, a VW can be created in suspended mode.
3. To start a suspended VW, use the following command :
   alter warehouse  xsmall resume.

Q. How do you stop a VW ?
===========================
1. To stop a running  VW, use the following command :
   alter warehouse xsmall suspend


Q.  Are there any  properties of warehouse that can be used to suspend and resume warehouse automatically ?
===========================================================================================================
1. Yes.
2. The following two properties can be set to control vw :
AUTO_SUSPEND = { <num> | NULL }
AUTO_RESUME = { TRUE | FALSE }

Q. How do we set these properties while creating a VW ?
=======================================================
create warehouse  vw1
auto_suspend=60  #  seconds
auto_resume=True 
INITIALLY_SUSPENDED = True ;

Note
1. VW will be created in suspended state.
2. When i a computational task is submitted, VW will be automatically resumed because auto_resume is set to True.
3. Once the computation is done, VW will be idle. Because auto_suspend is set to 60 seconds, VW will be automatically
   suspended after being idle for 60 seconds.

Q. What are the general characteristics of VW ?
===============================================
 
1. Warehouses consume credits while running:

2. A warehouse begins to consume credits once all the compute resources are provisioned for the warehouse.

3. In a rare instance when some of the compute resources fail to provision, the warehouse only consumes credits for the provisioned compute resources.

4. Once the remaining compute resources are successfully provisioned, the warehouse starts consuming credits for all requested compute resources.

5. While starting or resuming a warehouse often takes only a few seconds, in some instances, it can take longer as Snowflake provisions the compute 
   resources for the warehouse.

6. Snowflake does not begin executing SQL statements submitted to a warehouse until all of the compute resources for the warehouse are
   successfully provisioned, unless any of the resources fail to provision:

7. If any of the compute resources for the warehouse fail to provision during start-up, Snowflake attempts to repair the failed resources.

8. During the repair process, the warehouse starts processing SQL statements once 50% or more of the requested compute resources are successfully provisioned.

9. Credits are billed on a per-second basis while the warehouse is running, with a 1-minute minimum each time the warehouse is resumed;
    however, credit consumption is reported in 60-minute (i.e. hourly) increments.

10. A warehouse must be running and the current warehouse for the session (i.e. in use) to process SQL statements submitted in the session. 

# 
EOF
#
clear
echo -n "View the report;press ny key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
########################################################################################
# Name     : show_resource_monitor_primer
# Overview : The function shows resource monitor primer.
# Notes    : 
#########################################################################################
show_resource_monitor_primer()
{
#
cat <<EOF  > ${TEMP_FILE_1} 
#
                                                      Resource Monitor Primer
                                                      =======================

Q. What is resource monitor (RM)?
=================================
1. A RM is database object that can help control costs and avoid unexpected credit usage caused by running warehouses.

2. A virtual warehouse consumes Snowflake credits while it runs. You can use a resource monitor to monitor credit usage by virtual warehouses and
   the cloud services needed to support those warehouses. 

3. You can also set up a resource monitor to suspend a user-managed virtual warehouse when it reaches a credit limit.


Q. How does RM work ?
=====================
1. You define a RM with its properties.
2. You then assign a defined resource monitor to a warehouse with following statement:
alter warehouse test_warehgouse
RESOURCE_MONITOR  = test_rm ;


Q. What are the properties of  RM ?
====================================

Credit quota
============
Credit quota specifies the number of Snowflake credits allocated to the monitor for the specified frequency interval. Any number can be specified.

Monitor type
============
This property specifies whether the resource monitor is used to monitor your account or a specific set of individual warehouses:

Schedule
========
The default schedule for a resource monitor specifies that it starts monitoring credit usage immediately and the used credits reset to 0 
at the beginning of each calendar month (i.e. the start of the standard Snowflake billing cycle).

However, you can optionally customize the schedule for a resource monitor using the following properties:

Frequency
The interval at which the used credits reset relative to the specified start date.

Supported values:

Daily
Weekly
Monthly
Yearly
Never (used credits never reset; assigned warehouses continue using credits until the credit quota is reached)

Start
======
Date and time (i.e. timestamp) when the resource monitor starts monitoring the assigned warehouses.

Supported values:
Immediately (i.e. current timestamp)
Later (i.e. any future timestamp)

End
====
Date and time (i.e. timestamp) when Snowflake suspends the warehouses associated with the resource monitor, regardless of whether
the used credits reached any of the thresholds defined for the resourc

Actions
========
Also referred to as triggers, each action specifies a threshold, as a percentage of the credit quota for the resource monitor,
and the action to perform when the threshold is reached within the specified interval. Note that actions support thresholds greater than 100.

Resource monitors support the following actions:
================================================

Notify & Suspend
================
Send a notification and suspend all assigned warehouses after all statements being executed by the warehouse(s) have completed.

Notify & Suspend Immediately
=============================
Send a notification and suspend all assigned warehouses immediately, which cancels any statements being executed by the warehouses at the time.

Notify
=======
Perform no action on warehouses, but send a notification.

Usage Notes
===========
1. Triggers are optional; however, at least one trigger must be added to a resource monitor before it can perform any actions.

2. Each resource monitor supports up to a maximum of 5 NOTIFY action triggers.

3. After a resource monitor is created, it must be assigned to a warehouse or account before it can perform any monitoring actions:

4. To assign a warehouse to a resource monitor, use ALTER WAREHOUSE (or CREATE WAREHOUSE if you are creating the warehouse).

5. To assign a resource monitor at the account level, use ALTER ACCOUNT. The NOTIFY_USERS parameter must be null.

6. To view all resource monitors created in your account and their assignment, use the SHOW RESOURCE MONITORS command. 
   The command output displays NULL in the level column for resource monitors that are not assigned to the account or any warehouses and, 
   therefore, are not monitoring any credit usage.

7. If frequency and start_timestamp parameters are set on a resource monitor, the day for the credit usage reset is calculated based on those parameters. 
   The time the credit usage resets to 0 is 12:00 AM UTC regardless of the time specified in start_timestamp.

8. If you specify an end_timestamp, monitoring ends at that specified date and time and all assigned warehouses are suspended at that date and time even
   if the credit quota has not been reached.

9. When this occurs, a notification is sent that states the resource monitor has reached a percentage of its quota and has triggered a suspend immediate action.
   The percentage of the quota reflects the number of credits used in the current interval up to the end date and might not be a threshold you specified.

10. If there are non-administrator users in the notification list, the following notes apply:

11. If any user in the notification list does not have a verified email, the SQL statement fails.

12. If any user in the notification list changes their email address and does not verify the new email address, the notification silently fails.

13.The notification list is limited to a maximum number of 5 non-administrator users.

14. Account administrators can view the notification list of non-administrator users in the output of SHOW RESOURCE MONITORS in the notify_user column.

15. To receive notifications generated by resource monitors, account administrators and non-administrator users in the notification list must explicitly
    enable notifications in their preferences. In addition, to receive email notifications, users must have a verified email in their preferences.
    Preferences can only be set in the Snowflake web interface. For more information, see Enabling receipt of notifications.

EOF
#
clear
echo -n "View the report;press ny key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
#
########################################################################################
# Name     : show_all_virtual_warehouses
# Overview : The function shows details of all virtual warehouses
# Notes    : 
#########################################################################################
show_all_virtual_warehouses()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
/*
--
show warehouses;
--
create or replace table warehouse_details as
SELECT  *
FROM table (result_scan (last_query_id()) );
*/
--
--
/*
desc table warehouse_details;
+---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
| name                | type              | kind   | null? | default | primary key | unique key | check | expression | comment | policy name | privacy domain |
|---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------|
| name                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| state               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| type                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| size                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| running             | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| queued              | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_default          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_current          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| auto_suspend        | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| auto_resume         | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| available           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| provisioning        | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| quiescing           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| other               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| created_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resumed_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| updated_on          | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| comment             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resource_monitor    | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| actives             | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| pendings            | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| failed              | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| suspended           | NUMBER(9,0)       | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| uuid                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| budget              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner_role_type     | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| resource_constraint | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
+---------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
--
*/
--
SELECT
"name"        ,
"state"       ,
"type"        ,
"size"        ,
"running"     ,
"queued"      ,
"is_default"  ,
"is_current"  ,
"auto_suspend" ,
"auto_resume" 
FROM warehouse_details
ORDER by "name";
--
SELECT
"name"             ,
"available"        ,
"provisioning"     ,
"quiescing"        ,
"other"            ,
"created_on"       ,
"resumed_on"       ,
"updated_on"       ,
"owner"            ,
"comment"          ,
"resource_monitor" 
FROM warehouse_details
ORDER BY "name";
--
--
SELECT
"name"             ,
"actives"          ,
"pendings"         ,
"failed"           ,
"suspended"        ,
"uuid"             ,
"budget"           ,
"owner_role_type"  ,
"resource_constraint"
FROM warehouse_details
ORDER BY "name";
--
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Warehouse Details"  > ${REPORT_FILE}
echo  "================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : show_all_resource_monitors
# Overview : The function shows details of all resource monitors.
# Notes    : 
#########################################################################################
show_all_resource_monitors()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
--
/*
show resource monitors ;
--
create or replace table resource_monitor_details as 
select *
from table (result_scan ( last_query_id()) );
--
desc  table resource_monitor_details ;
--
+------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
| name                   | type              | kind   | null? | default | primary key | unique key | check | expression | comment | policy name | privacy domain |
|------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------|
| name                   | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| credit_quota           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| used_credits           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| remaining_credits      | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| level                  | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| frequency              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| start_time             | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| end_time               | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| notify_at              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| suspend_at             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| suspend_immediately_at | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| created_on             | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner                  | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| comment                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| notify_users           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
+------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
15 Row(s) produced. Time Elapsed: 0.048s
*/
--
SELECT
"name"            ,
"credit_quota"    ,
"used_credits"     ,
"remaining_credits",
"level"          ,
"frequency"      ,
"start_time"     ,
"end_time"
FROM resource_monitor_details
ORDER by "name";
--
--
SELECT
"name"                  ,
"notify_at"             ,
"suspend_at"            ,
"suspend_immediately_at",
"created_on"  ,
"owner"       ,
"comment"     ,
"notify_users"
FROM resource_monitor_details
ORDER by "name";
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Resource Monitor Details"  > ${REPORT_FILE}
echo  "======================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
#
#
########################################################################################
# Name     : create_virtual_warehouse
# Overview : The function creates a virtual warehouse
# Notes    : 
#########################################################################################
create_virtual_warehouse()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
/*
CREATE [ OR REPLACE ] WAREHOUSE [ IF NOT EXISTS ] <name>
       [ [ WITH ] objectProperties ]
       [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
       [ objectParams ]
Where:

objectProperties ::=
  WAREHOUSE_TYPE = { STANDARD | 'SNOWPARK-OPTIMIZED' }
  WAREHOUSE_SIZE = { XSMALL | SMALL | MEDIUM | LARGE | XLARGE | XXLARGE | XXXLARGE | X4LARGE | X5LARGE | X6LARGE }
  RESOURCE_CONSTRAINT = { MEMORY_1X | MEMORY_1X_x86 | MEMORY_16X | MEMORY_16X_x86 | MEMORY_64X | MEMORY_64X_x86 }
  MAX_CLUSTER_COUNT = <num>
  MIN_CLUSTER_COUNT = <num>
  SCALING_POLICY = { STANDARD | ECONOMY }
  AUTO_SUSPEND = { <num> | NULL }
  AUTO_RESUME = { TRUE | FALSE }
  INITIALLY_SUSPENDED = { TRUE | FALSE }
  RESOURCE_MONITOR = <monitor_name>
  COMMENT = '<string_literal>'
  ENABLE_QUERY_ACCELERATION = { TRUE | FALSE }
  QUERY_ACCELERATION_MAX_SCALE_FACTOR = <num>

objectParams ::=
  MAX_CONCURRENCY_LEVEL = <num>
  STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = <num>
  STATEMENT_TIMEOUT_IN_SECONDS = <num>

*/
--
--
create or replace warehouse test_vw 
WAREHOUSE_TYPE    =  STANDARD
MAX_CLUSTER_COUNT = 1
MIN_CLUSTER_COUNT = 1
--SCALING_POLICY  = STANDARD  for multi clustered warehouse only
AUTO_SUSPEND      = 60
AUTO_RESUME       = TRUE
INITIALLY_SUSPENDED = TRUE  ;
--
show warehouses like 'test_vw%';
--
--
EOF2
#
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Resource Monitor Details"  > ${REPORT_FILE}
echo  "======================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
########################################################################################
# Name     : create_resource_monitor
# Overview : The function creates a resource monitor
# Notes    : 
#########################################################################################
create_resource_monitor()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
/*
CREATE [ OR REPLACE ] RESOURCE MONITOR [ IF NOT EXISTS ] <name> WITH
                      [ CREDIT_QUOTA = <number> ]
                      [ FREQUENCY = { MONTHLY | DAILY | WEEKLY | YEARLY | NEVER } ]
                      [ START_TIMESTAMP = { <timestamp> | IMMEDIATELY } ]
                      [ END_TIMESTAMP = <timestamp> ]
                      [ NOTIFY_USERS = ( <user_name> [ , <user_name> , ... ] ) ]
                      [ TRIGGERS triggerDefinition [ triggerDefinition ... ] ]
Copy
Where:

triggerDefinition ::=
    ON <threshold> PERCENT DO { SUSPEND | SUSPEND_IMMEDIATE | NOTIFY }
*/
--
CREATE or REPLACE RESOURCE MONITOR  test_rm  with
credit_quota    = 1
frequency       = daily
start_timestamp = immediately
end_timestamp   = '2025-04-01'  -- YYYY-MM-DAY
notify_users=  (azaman)
TRIGGERS ON 75 PERCENT DO NOTIFY
         ON 100 PERCENT DO SUSPEND
         ON 110 PERCENT DO SUSPEND_IMMEDIATE;
--
EOF2
#
##
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Resource Monitor Details"  > ${REPORT_FILE}
echo  "======================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
########################################################################################
# Name     : update_resource_monitor
# Overview : The function updates a  resource monitor
# Notes    : 
#########################################################################################
update_resource_monitor()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
/*
CREATE [ OR REPLACE ] RESOURCE MONITOR [ IF NOT EXISTS ] <name> WITH
                      [ CREDIT_QUOTA = <number> ]
                      [ FREQUENCY = { MONTHLY | DAILY | WEEKLY | YEARLY | NEVER } ]
                      [ START_TIMESTAMP = { <timestamp> | IMMEDIATELY } ]
                      [ END_TIMESTAMP = <timestamp> ]
                      [ NOTIFY_USERS = ( <user_name> [ , <user_name> , ... ] ) ]
                      [ TRIGGERS triggerDefinition [ triggerDefinition ... ] ]
Copy
Where:

triggerDefinition ::=
    ON <threshold> PERCENT DO { SUSPEND | SUSPEND_IMMEDIATE | NOTIFY }
*/
--
alter resource monitor test_rm
SET credit_quota = 2 ;
--
show resource monitors like 'test_rm%';
--
--
EOF2
#
##
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Resource Monitor Details"  > ${REPORT_FILE}
echo  "======================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
########################################################################################
# Name     : update_virtual_warehouse
# Overview : The function updates a  virtual warehouse
# Notes    : 
#########################################################################################
update_virtual_warehouse()
{
#
DT=`date "+%d\%m\%Y %H:%M:%S"`
create_outer_wrapper_script()
{
cat <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
# write the script
# 
cat <<EOF2 > ${SQL_SCRIPT}
--
!set echo=True;
--
/*
CREATE [ OR REPLACE ] WAREHOUSE [ IF NOT EXISTS ] <name>
       [ [ WITH ] objectProperties ]
       [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
       [ objectParams ]
Where:

objectProperties ::=
  WAREHOUSE_TYPE = { STANDARD | 'SNOWPARK-OPTIMIZED' }
  WAREHOUSE_SIZE = { XSMALL | SMALL | MEDIUM | LARGE | XLARGE | XXLARGE | XXXLARGE | X4LARGE | X5LARGE | X6LARGE }
  RESOURCE_CONSTRAINT = { MEMORY_1X | MEMORY_1X_x86 | MEMORY_16X | MEMORY_16X_x86 | MEMORY_64X | MEMORY_64X_x86 }
  MAX_CLUSTER_COUNT = <num>
  MIN_CLUSTER_COUNT = <num>
  SCALING_POLICY = { STANDARD | ECONOMY }
  AUTO_SUSPEND = { <num> | NULL }
  AUTO_RESUME = { TRUE | FALSE }
  INITIALLY_SUSPENDED = { TRUE | FALSE }
  RESOURCE_MONITOR = <monitor_name>
  COMMENT = '<string_literal>'
  ENABLE_QUERY_ACCELERATION = { TRUE | FALSE }
  QUERY_ACCELERATION_MAX_SCALE_FACTOR = <num>

objectParams ::=
  MAX_CONCURRENCY_LEVEL = <num>
  STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = <num>
  STATEMENT_TIMEOUT_IN_SECONDS = <num>

*/
--
alter warehouse test_vw
SET resource_monitor = test_rm ;
--
show warehouses like 'test_vw%';
--
--
EOF2
#
##
snowsql ${CONNECT_STRING}  > ${LOG_FILE}  2>&1
#
# Prepare header for report
# 
echo  "Resource Monitor Details"  > ${REPORT_FILE}
echo  "======================="  >> ${REPORT_FILE}
echo -e "\n"               >> ${REPORT_FILE}
#
cat  ${LOG_FILE} >> ${REPORT_FILE}
#
#
echo -n "View report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
########################################################################################
# Name     : display_virtual_warehouse_management_menu
# Overview : The function displays virtual management menu.
# Notes :
#########################################################################################
display_virtual_warehouse_management_menu()
{
MENU_NAME=vwam
clear

while true
do
clear

echo  -n "
######################################
#    Virtual Warehouse Management    #
#                                    #
#   5. Virtual Warehouse Primer      # 
#  10. Resource Monitor Primer       # 
#  15. Show All Virtual Warehouses   # 
#  20. Show All Resource Monitors    #
#  25. Create Resource Monitor       #
#  30. Create Virtual Warehouse      #
#  35. Update Resource Monitor       #
#  40. Update Virtual Warehouse      #
#                                    #
#  98. Root Menu                     #      
#  99. Exit                          #      
#                                    #
# TT=Time Travel FS=FailSafe         #
######################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
done
}
#
#
#
#
########################################################################################
# Name     : show_dynamic_table_primer
# Overview : The function shows dynamic table primer.
# Notes :
#########################################################################################
show_dynamic_table_primer()
{

cat <<EOF  > ${TEMP_FILE_1}

                              DYNAMIC TABLE  PRIMER
                              =====================

Q. What are dynamic tables ?
============================
1. Dynamic tables are the building blocks of declarative data transformation pipelines.

2. They significantly simplify data engineering in Snowflake and provide a reliable, cost-effective,
   and automated way to transform your data for consumption.

3. Instead of defining data transformation steps as a series of tasks and then monitoring dependencies 
   and scheduling, you can simply define the end state of the transformation using dynamic tables and
   leave the complex pipeline management to Snowflake.

4. A dynamic table materializes the results of a query that you specify.

5. Instead of creating a separate target table and writing code to transform and update the data in that table,
   you can define the target table as a dynamic table, and you can specify the SQL statement that performs
   the transformation. 

6. An automated process updates the materialized results automatically through regular refreshes.

7. Because the content of a dynamic table is fully determined by the given query, the content cannot be
   changed by using DML.

8. You don’t insert, update, or delete the rows in a dynamic table.

9. The automated refresh process materializes the query results into a dynamic table.

                           dynamic table        transformation is done 
                           being updated with   within SELECT statement
                           the query output
Query is executed--------------------------------------------------------------->Dynamic Table
at regular interval                                                             (target table)
source table/s
LAG=how frequently should the query be 
     executed ?
T0=Source  Table updated
T1=query is executed
LAG=T1 - T0


Source Table-------------------->Dynamic Table-1 -------------------------------> Dynamic table-2
Query gives data---------------->Query gives data------------------------------->                   



Full Syntax for Dynamic Table Creation
======================================

CREATE [ OR REPLACE ] [ TRANSIENT ] DYNAMIC TABLE [ IF NOT EXISTS ] <name> (
    -- Column definition
    <col_name> <col_type>
      [ [ WITH ] MASKING POLICY <policy_name> [ USING ( <col_name> , <cond_col1> , ... ) ] ]
      [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
      [ COMMENT '<string_literal>' ]

    -- Additional column definitions
    [ , <col_name> <col_type> [ ... ] ]

  )
  TARGET_LAG = { '<num> { seconds | minutes | hours | days }' | DOWNSTREAM }
  WAREHOUSE = <warehouse_name>

  [ REFRESH_MODE = { AUTO | FULL | INCREMENTAL } ]
  [ INITIALIZE = { ON_CREATE | ON_SCHEDULE } ]
  [ CLUSTER BY ( <expr> [ , <expr> , ... ] ) ]
  [ DATA_RETENTION_TIME_IN_DAYS = <integer> ]
  [ MAX_DATA_EXTENSION_TIME_IN_DAYS = <integer> ]
  [ COMMENT = '<string_literal>' ]
  [ [ WITH ] ROW ACCESS POLICY <policy_name> ON ( <col_name> [ , <col_name> ... ] ) ]
  [ [ WITH ] TAG ( <tag_name> = '<tag_value>' [ , <tag_name> = '<tag_value>' , ... ] ) ]
  [ REQUIRE USER ]

  AS <query>



Parameter Descriptions
======================

TARGET_LAG = { num { seconds | minutes | hours | days } | DOWNSTREAM }
==========
Specifies the lag for the dynamic table:

'num seconds | minutes | hours | days'
Specifies the maximum amount of time that the dynamic table’s content should lag behind updates to the source tables.

For example:

If the data in the dynamic table should lag by no more than 5 minutes, specify 5 minutes.

If the data in the dynamic table should lag by no more than 5 hours, specify 5 hours.

If the dynamic table depends on another dynamic table, the minimum target lag must be greater than or equal to the target lag of the dynamic table it depends on.

DOWNSTREAM
===========
Specifies that the dynamic table should be refreshed only when dynamic tables that depend on it are refreshed.

WAREHOUSE = warehouse_name
==========
Specifies the name of the warehouse that provides the compute resources for refreshing the dynamic table.

You must use a role that has the USAGE privilege on this warehouse in order to create the dynamic table. 




TRANSIENT
==========
1. Default: No value. If a dynamic table is not declared as TRANSIENT, it is permanent.

REFRESH_MODE = { AUTO | FULL | INCREMENTAL }
============
1. Specifies the refresh mode for the dynamic table.
2. This property cannot be altered after you create the dynamic table. To modify the property, recreate the dynamic table with a
   CREATE OR REPLACE DYNAMIC TABLE command.

AUTO
====
1. When refresh mode is AUTO, the system attempts to apply an incremental refresh by default. However, when incremental refresh isn’t supported or
   expected to perform well, the dynamic table automatically selects full refresh instead.

To determine the best mode for your use case, experiment with refresh modes and automatic recommendations. 
For consistent behavior across Snowflake releases, explicitly set the refresh mode on all dynamic tables.

To verify the refresh mode for your dynamic tables, see View dynamic table refresh mode.

FULL
====
1. Enforces a full refresh of the dynamic table, even if the dynamic table can be incrementally refreshed.

INCREMENTAL
===========
1. Enforces an incremental refresh of the dynamic table.
2. If the query that underlies the dynamic table can’t perform an incremental refresh, dynamic table creation fails and displays an error message.

Default: AUTO


INITIALIZE
==========
1. Specifies the behavior of the initial refresh of the dynamic table.
2. This property cannot be altered after you create the dynamic table. 
3. To modify the property, replace the dynamic table with a CREATE OR REPLACE DYNAMIC TABLE command.

ON_CREATE
=========
Refreshes the dynamic table synchronously at creation. If this refresh fails, dynamic table creation fails and displays an error message.

ON_SCHEDULE
============
Refreshes the dynamic table at the next scheduled refresh.

The dynamic table is populated when the refresh schedule process runs. No data is populated when the dynamic table is created. If you try to query the table using SELECT * FROM DYNAMIC TABLE, you might see the following error because the first scheduled refresh has not yet occured.

Dynamic Table is not initialized. Please run a manual refresh or wait for a scheduled refresh before querying.
Default: ON_CREATE

COMMENT 'string_literal'
Specifies a comment for the column.

(Note that comments can be specified at the column level or the table level. The syntax for each is slightly different.)

MASKING POLICY = policy_name
==============
Specifies the masking policy to set on a column.

column_list
If you want to change the name of a column or add a comment to a column in the dynamic table, include a column list that specifies the column names and, if needed, comments about the columns. You do not need to specify the data types of the columns.

If any of the columns in the dynamic table are based on expressions - for example, not simple column names - then you must supply a column name for each column in the dynamic table. For instance, the column names are required in the following case:

CREATE DYNAMIC TABLE product (pre_tax_profit, taxes, after_tax_profit)
  TARGET_LAG = '20 minutes'
    WAREHOUSE = mywh
    AS
      SELECT revenue - cost, (revenue - cost) * tax_rate, (revenue - cost) * (1.0 - tax_rate)
      FROM staging_table;
You can specify an optional comment for each column. For example:

CREATE DYNAMIC TABLE product (pre_tax_profit COMMENT 'revenue minus cost',
                taxes COMMENT 'assumes taxes are a fixed percentage of profit',
                after_tax_profit)
  TARGET_LAG = '20 minutes'
    WAREHOUSE = mywh
    AS
      SELECT revenue - cost, (revenue - cost) * tax_rate, (revenue - cost) * (1.0 - tax_rate)
      FROM staging_table;
CLUSTER BY ( expr [ , expr , ... ] )

Specifies one or more columns or column expressions in the dynamic table as the clustering key. Before you specify a clustering key for a dynamic table, you should understand micro-partitions. For more information, see Understanding Snowflake Table Structures.

Note the following when using clustering keys with dynamic tables:

Column definitions are required and must be explicitly specified in the statement.

By default, Automatic Clustering is not suspended for the new dynamic table, even if Automatic Clustering is suspended for the source table.

Clustering keys are not intended or recommended for all tables; they typically benefit very large (for example multi-terabyte) tables.

Specifying CLUSTER BY doesn’t cluster the data at creation time; instead, CLUSTER BY relies on Automatic Clustering to recluster the data over time.

For more information, see Clustering Keys & Clustered Tables.

Default: No value (no clustering key is defined for the table)

DATA_RETENTION_TIME_IN_DAYS = integer
============================
Specifies the retention period for the dynamic table so that Time Travel actions (SELECT, CLONE) can be performed on historical data in the dynamic table. Time Travel behaves the same way for dynamic tables as it behaves for traditional tables. For more information, see Understanding & using Time Travel.


MAX_DATA_EXTENSION_TIME_IN_DAYS = integer
================================
An object parameter that sets the maximum number of days Snowflake can extend the data retention period to prevent streams on the dynamic table from becoming stale.


COMMENT = 'string_literal'
========
Specifies a comment for the dynamic table.

Default: No value.

COPY GRANTS
===========
Specifies to retain the access privileges from the original dynamic table when a new dynamic table is created using the CREATE DYNAMIC TABLE … CLONE variant.

This parameter copies all privileges, except OWNERSHIP, from the existing dynamic table to the new dynamic table. The new dynamic table does not inherit any future grants defined for the object type in the schema. By default, the role that executes the CREATE DYNAMIC TABLE statement owns the new dynamic table.

If this parameter is not included in the CREATE DYNAMIC TABLE statement, then the new table does not inherit any explicit access privileges granted on the original dynamic table, but does inherit any future grants defined for the object type in the schema.

Note:

With data sharing:

If the existing dynamic table was shared to another account, the replacement dynamic table is also shared.

If the existing dynamic table was shared with your account as a data consumer, and access was further granted to other roles in the account (using GRANT IMPORTED PRIVILEGES on the parent database), access is also granted to the replacement dynamic table.

The SHOW GRANTS output for the replacement dynamic table lists the grantee for the copied privileges as the role that executed the CREATE TABLE statement, with the current timestamp when the statement was executed.

The SHOW GRANTS output for the replacement dynamic table lists the grantee for the copied privileges as the role that executed the CREATE TABLE statement, with the current timestamp when the statement was executed.

The operation to copy grants occurs atomically in the CREATE DYNAMIC TABLE command (i.e. within the same transaction).

Important

The COPY GRANTS parameter can be placed anywhere in a CREATE [ OR REPLACE ] DYNAMIC TABLE command, except after the query definition.

For example, the following dynamic table will fail to create:

CREATE OR REPLACE DYNAMIC TABLE product
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = mywh
  AS
    SELECT * FROM staging_table
    COPY GRANTS;

ROW ACCESS POLICY policy_name ON ( col_name [ , col_name ... ] )
========================
Specifies the row access policy to set on a dynamic table.

TAG ( tag_name = 'tag_value' [ , tag_name = 'tag_value' , ... ] )
====
1. Specifies the tag name and the tag string value.
2. The tag value is always a string, and the maximum number of characters for the tag value is 256.


REQUIRE USER
=============
1. When specified, the dynamic table cannot run unless a user is specified.
2. The dynamic table is not able to refresh unless a user is set in a manual refresh with the COPY SESSION parameter specified.
3. If this option is enabled, the dynamic table must be created with the ON_SCHEDULE parameter for INITIALIZE.





Example
=======
1. The example in Transforming Loaded JSON Data on a Schedule uses streams and tasks to transform and
    insert new data into two target tables (name and visits) as the data is streamed into a landing table (raw).

The following examples demonstrate how to perform the same transformation using dynamic tables.

SQL Statements for Streams and Tasks
====================================
--
-- Create a landing table to store
-- raw JSON data.
--
CREATE OR REPLACE TABLE raw
(var VARIANT);
--
-- Create a stream to capture inserts
-- to the landing table.
--
CREATE OR REPLACE STREAM rawstream1
ON TABLE raw;
--
-- Create a table that stores the names
-- of office visitors from the raw data.
--
CREATE OR REPLACE TABLE names
(id INT,
first_name STRING,
last_name STRING);
--
-- Create a task that inserts new name
-- records from the rawstream1 stream
-- into the names table.
-- Execute the task every minute when
-- the stream contains records.
--
CREATE OR REPLACE TASK raw_to_names
WAREHOUSE = mywh
SCHEDULE = '1 minute'
WHEN
SYSTEM$STREAM_HAS_DATA('rawstream1')
AS
MERGE INTO names n
USING (
SELECT var:id id, var:fname fname,
var:lname lname FROM rawstream1
) r1 ON n.id = TO_NUMBER(r1.id)
WHEN MATCHED AND metadata$action = 'DELETE' THEN
DELETE
WHEN MATCHED AND metadata$action = 'INSERT' THEN
UPDATE SET n.first_name = r1.fname, n.last_name = r1.lname
WHEN NOT MATCHED AND metadata$action = 'INSERT' THEN
INSERT (id, first_name, last_name)
VALUES (r1.id, r1.fname, r1.lname);
--
SQL Statements for Dynamic Tables
=================================
-- Create a landing table to store
-- raw JSON data.
--
CREATE OR REPLACE TABLE raw
(var VARIANT);
--
-- Create a dynamic table containing the
-- names of office visitors from
-- the raw data.
-- Try to keep the data up to date within
-- 1 minute of real time.
--
CREATE OR REPLACE DYNAMIC TABLE names
TARGET_LAG = '1 minute'
WAREHOUSE = mywh
AS
SELECT var:id::int id, var:fname::string first_name,
var:lname::string last_name FROM raw;
--
--
Notes
=====
1. As this example shows, when creating a dynamic table, you specify the query for the results that you want
   to see.

2. For the incremental refresh of the data, you don’t need to create a stream to track changes and write a
   task to examine those changes and apply the changes to the target table. 

3. The automated refresh process does this for you based on the query that you specify.

Q When do we  use dynamic tables ?
=================================
There are several methods of transforming data in your pipeline (for example, streams and tasks, CTAS, your own custom solution). Dynamic tables are one option for transforming your data.

Q. Where are dynamic tables best used ?
=======================================
Dynamic tables are best used when:

1. You don’t want to write code to track data dependencies and manage data refresh.

2. You don’t need, or want to avoid, the complexity of streams and tasks.

3. You do need to materialize the results of a query of multiple base tables.

4. You need to build multiple tables to transform data via an ETL pipeline.

5. You don’t need fine-grained refresh schedule control and you just want to specify the target data 
   freshness for your pipelines.

6. You don’t need to use unsupported dynamic query constructs such as stored procedures, non-deterministic
   functions not listed in Non-deterministic functions supported in dynamic tables,
   or external functions, or need to use sources for dynamic tables that are external tables, 
   streams, or materialized views.

Note
====
1. Dynamic tables can be used as the source of a stream.

2. When used together, a stream based on a dynamic table works like any other stream. 

Q How do dynamic tables work ?
==============================
When creating a dynamic table, you specify the query used to transform the data from one or more base objects or dynamic tables. An automated refresh process executes this query regularly and updates the dynamic table with the changes made to the base objects.

How does a dynamic table compare with  streams/tasks ?
=======================================================
This automated process computes the changes that were made to the base objects and merges those changes into the dynamic table. To perform this work, the process uses compute resources that you associate with the dynamic table. For more information on resources refer to Understanding the costs of dynamic tables.

When creating a dynamic table, you specify a target “freshness” for the data (a target lag). For example, you can specify that the data should be at most five minutes behind the updates to the base table. Based on this target freshness, the automated process sets up refreshes so that the data in the dynamic table is kept up to date within this target (that is, within five minutes of updates to the base table).

If the data does not need to be as fresh, you can specify a longer target freshness time to reduce costs. For example, if the data in the target table just needs to be at most one hour behind the updates to the base tables, you can specify a target freshness of one hour (instead of five minutes) to reduce costs.

About chaining together pipelines of dynamic tables
You can set up a dynamic table to query other dynamic tables.

For example, suppose that your data pipeline retrieves data from a staging table to update separate dimension tables for customer, product, and date and time data. Your pipeline also updates a table containing aggregate sales data, based on the dimension tables.

You can set up the dimension tables as dynamic tables that query the staging table. You can then set up the aggregate sales table as a dynamic table that queries the dimension tables.

This is similar to defining a directed acyclic graph (DAG) of tasks. In a DAG of tasks, the task that updates the aggregate sales table runs only if the tasks to update the dimension tables have run to completion without errors.

Comparison between DAGs for streams / tasks and dynamic tables
If a dynamic table queries another dynamic table, the automated refresh process updates all dependent dynamic tables at the appropriate time in order to ensure that their lag targets are met and the data is consistent.

Understanding the privileges required for dynamic tables
The following sections explain the privileges required to create and work with dynamic tables:

Privileges required to create dynamic tables
============================================

Dynamic tables privileges

Dynamic tables privileges
The following table describes the privileges required for managing dynamic tables:

Privilege

Usage

SELECT

Enables executing a SELECT statement on a dynamic table.

OPERATE

Required to alter properties of a dynamic table, including:

ALTER … SUSPEND: Suspend a dynamic table.

ALTER … RESUME: Resume a dynamic table.

ALTER … REFRESH: Refresh a dynamic table.

WAREHOUSE and TARGET_LAG.

OWNERSHIP

Grants full control over the dynamic table. Only a single role can hold this privilege on a specific object at a time.

ALL [ PRIVILEGES ]

Grants all privileges, except OWNERSHIP, on the dynamic table.

Dynamic tables and time travel
==============================
Snowflake Time Travel enables accessing historical data (i.e. data that has been changed or deleted) at any point within a defined period. Time Travel behaves identically for Dynamic Tables as it does for traditional tables.

For more information refer to Snowflake Time Travel & Fail-safe.

Dynamic tables and replication
===============================
Replication support for dynamic tables enables you to copy data from a primary database to a secondary database for either disaster recovery or data sharing. It can serve as either a failover preparation strategy for disaster recovery or as a means of sharing data across deployments for read-only purposes.

Replicated dynamic tables behave differently depending on if the primary database that contains the dynamic table is replicated in a replication group or a failover group. For more information, see Replication and Dynamic Tables.


EOF
#
#
echo -n "View dynamic table primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
#
########################################################################################
# Name     : create_dynamic_table
# Overview : The function displays dynamic management menu.
# Notes :
#########################################################################################
create_dynamic_table ()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- create source table
--
create or replace table products( nkey varchar(10), sku number(10), prod_desc  varchar(20));
--
-- column data types will be inferred
-- minimum lag must be 1 minute
--
create or replace  dynamic table hub_product ( skey, nkey , sku , prod_desc, valid_from , valid_to  )
target_lag = '1 minute'
warehouse = xsmall
as
SELECT 100, nkey, sku, prod_desc,current_date(),null
FROM products;
--
EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
########################################################################################
# Name     : monitor_dynamic_table
# Overview : The function monitors dynamic table.
# Notes :
#########################################################################################
monitor_dynamic_table ()
{
#
while true
do
    echo -n "Creating source and dynamic tables;press any key to continue..."
    read DUMmY
    create_dynamic_table

    cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- insert record into source table
--
insert into products values
(100,9999, 'PROD-1');
--
--
EOF2
#
   clear
   echo -n "Inserting recodrs into product table;press any key to continue..."
   read DUMMY
   view  ${SQL_SCRIPT}                                               
   snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
   #
   echo "                Log Details"  > ${REPORT_FILE}
   echo "                ==========="  >> ${REPORT_FILE}
   cat ${LOG_FILE} >> ${REPORT_FILE}

   clear
   echo -n "View the log;press any key to continue..."
   read DUMMY
   view ${REPORT_FILE}
   #
   clear
   echo -n "killing 60 seconds before querying the dynamic table,press any key to continue.."
   read DUMMY
   sleep 60
   #
   # query target table
   # 
  cat  <<EOF3  > ${SQL_SCRIPT}                                               
!set echo=True
--
--query dynamic table
--
SELECT *
FROM hub_product;
--
EOF3

  clear
  echo -n "Query dynamic table;press any key to continue..."
  read DUMMY
  view  ${SQL_SCRIPT}                                               
  snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
  
  echo "                Log Details"  > ${REPORT_FILE}
  echo "                ==========="  >> ${REPORT_FILE}
  cat ${LOG_FILE} >> ${REPORT_FILE}

  clear
  echo -n "View dynamic table records;press any key to continue..."
  read DUMMY
  view ${REPORT_FILE}

  if  get_yn_acknowledgement "Do you wish to continue viewing/editing dynamic table(Y/N):"
  then
        continue
  else
       break
  fi

done
#
#
}
#
#
########################################################################################
# Name     : query_dt_metadata
# Overview : The function queries dynamic table metadata
# Notes    : 1. The metadata table name :
#                snowflake.account_usage.dynamic_table_refresh_history
#########################################################################################
query_dt_metadata()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- 
--
SELECT name as dt_table_name,
       database_name,
       schema_name,
       refresh_start_time,
       refresh_end_time,
       target_lag_sec,
       refresh_trigger,
       refresh_action,
       state_message
FROM snowflake.account_usage.dynamic_table_refresh_history
ORDER by 1,4 desc;
--
EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Dynamic Table Refresh History"  > ${REPORT_FILE}
echo "                ============================="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
########################################################################################
# Name     : show_all_dynamic_tables
# Overview : The function shows all dynamic tables
# Notes :
#########################################################################################
show_all_dynamic_tables()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
/*
show dynamic  tables;
*/
--
/*
CREATE or REPLACE table dt_show  as
SELECT  *
FROM table (result_scan(last_query_id() ) );
*/
--
/*
desc table dt_show;
*/
--
/*
desc table dt_show;
+----------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
| name                 | type              | kind   | null? | default | primary key | unique key | check | expression | comment | policy name | privacy domain |
|----------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------|
| created_on           | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| name                 | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| database_name        | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| schema_name          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| cluster_by           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| rows                 | NUMBER(38,0)      | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| bytes                | NUMBER(38,0)      | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| target_lag           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| refresh_mode         | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| refresh_mode_reason  | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| warehouse            | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| comment              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| text                 | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| automatic_clustering | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| scheduling_state     | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| last_suspended_on    | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_clone             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_replica           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_iceberg           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| data_timestamp       | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner_role_type      | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
+----------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
22 Row(s) produced. Time Elapsed: 0.080s
*/
--
SELECT
"name",
"database_name", 
"schema_name",
"target_lag",
"refresh_mode",
"refresh_mode_reason",
"warehouse",
"rows",
"bytes",
"is_clone",
"scheduling_state"
FROM dt_show;

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
########################################################################################
# Name     : drop_dynamic_table
# Overview : The function drops existing dynamic table.
# Notes :
#########################################################################################
drop_dynamic_table ()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- drop dynamic table
--
drop  dynamic table hub_product;
--
EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
########################################################################################
# Name     : display_dynamic_table_management_menu
# Overview : The function displays dynamic management menu.
# Notes :
#########################################################################################
display_dynamic_table_management_menu ()
{
MENU_NAME=dtam
clear

while true
do
clear

echo  -n "
######################################
#    Dynamic Table Management        #
#                                    #
#   5. Dynamic Table Primer          # 
#  10. Create Dynamic Table          # 
#  15. Monitor Dynamic Table         # 
#  20. Query DT Metadata             # 
#  25. Show All DTs                  # 
#  30. Drop Existing DTs             # 
#                                    #
#  98. Root Menu                     #      
#  99. Exit                          #      
#                                    #
# DT=Dynamic Table                   #
######################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
done
}
#
#
#
########################################################################################
# Name     : list_all_cloned_tables
# Overview : The function lists all cloned tables
# Notes :
#########################################################################################
list_all_cloned_tables()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- list all cloned tables
--
with cloned_tab_cte as
(
SELECT id,clone_group_id, decode(id,clone_group_id, 'N','Y') cloned
FROM snowflake.account_usage.table_storage_metrics
WHERE  cloned = 'Y'
), all_tab_cte as
(
SELECT table_name,table_catalog,table_schema,tsm.id,tsm.clone_group_id,decode(tsm.id,tsm.clone_group_id, 'N','Y') cloned,
       active_bytes,failsafe_bytes, retained_for_clone_bytes,time_travel_bytes
FROM snowflake.account_usage.table_storage_metrics tsm,
     cloned_tab_cte ctc
WHERE  (  
       tsm.id =  ctc.id 
            or
       tsm.id = ctc.clone_group_id 
           ) and
      tsm.deleted = FALSE
), final as
(
SELECT *
FROM all_tab_cte
)
SELECT *
FROM final
ORDER by id;
--
--
EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#  
#  
########################################################################################
# Name     : show_zcc_primer
# Overview : The function shows zcc primer
# Notes :
#########################################################################################
show_zcc_primer()
{
cat <<EOF > ${TEMP_FILE_1}

            Zero Copy Clone Primer
            ======================

Q. What is zero copy cloning (ZCC) ?
====================================
1. ZCP is a database activity that can copy any object from source to destination without copying the data physically.

Q. How does ZCC work ?
======================
1. ZCP is a metadata activity.
2. ZCP copies pointers for current MPs for the source object to target object.
3. All queries will be  parsed and serviced looking at MPs of source object.
4. Once new records are created in object table, this data will be stored new MPs in target object.

Q. What are the storage details for ZCC ?
=========================================
1. It will occupy no storage.
2. While retrieving records from cloned table, it will query MPs for clone's source table.

Q. What are the storage details for modified cloned table ?
===========================================================
1. It will occupy storage for new and modified records
2. While retrieving records from cloned table, it will query MPs for clone's source table for unchanged data and
   MPs for cloned table for new and modified data.

Q. What are the storage details for cloned table when source table is dropped ?
===============================================================================
1. If clone's source table is dropped, sf will maintain all it MPs(micro partitions) to service the cloned table.

Q. What are the recommended best practices when cloning an object ?
===================================================================
1. Refrain, if possible, from executing DML transactions on the source object (or any of its children) until after the cloning operation completes.

2. If this is not possible, prior to starting cloning, set DATA_RETENTION_TIME_IN_DAYS=1 for all tables in the schema
    (or database if you are cloning an entire database). Once the operation completes, remember to reset the parameter value back
     to 0 for those tables in the source, if desired.

3. You might also want to set the value to 0 for the cloned tables (if you plan to make DML changes to the cloned tables and do not wish
    to incur additional storage costs for Time Travel on the tables).

Q. How to identify ZCC tables ?
===============================
1. Query snowflake.information_schema.table_storage_metrics

2. Use the following decode statement to identify ZCC tables:

    - If id and clone_group_id is different, it's a clone table
    - SELECT  table_catalog,table_schema,table_name, id, decode(id,clone_group_id, 'N', 'Y') Cloned

--
--
drop  table scratch.workspace.src_tab;
create table scratch.workspace.src_tab ( id  number(4));
--
insert into scratch.workspace.src_tab values
(1),
(2),
(3),
(4);
--
show tables like '%SRC_TAB%';
--
-- create a table to store information displayed by show tables <table name> command
--
create or replace table scratch.workspace.src_tab_show_info as
select *
from table (result_scan(last_query_id()));
--
select *
from  scratch.workspace.src_tab_show_info ;
--

drop table  scratch.workspace.cln_tab;
CREATE OR REPLACE  TABLE scratch.workspace.cln_tab
     CLONE
scratch.workspace.src_tab;
--
show tables like '%CLN_TAB%';
--
create or replace table scratch.workspace.cln_tab_show_info as
select *
from table (result_scan(last_query_id()));
--
select *
from  scratch.workspace.cln_tab_show_info ;
--
--
/*
-- show information captured from show tables <table> command
--
desc table scratch.workspace.src_tab_show_info ;
+-------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
| name                    | type              | kind   | null? | default | primary key | unique key | check | expression | comment | policy name | privacy domain |
|-------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------|
| created_on              | TIMESTAMP_LTZ(3)  | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| name                    | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| database_name           | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| schema_name             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| kind                    | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| comment                 | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| cluster_by              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| rows                    | NUMBER(38,0)      | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| bytes                   | NUMBER(38,0)      | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner                   | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| retention_time          | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| automatic_clustering    | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| change_tracking         | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_external             | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| enable_schema_evolution | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| owner_role_type         | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_event                | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| budget                  | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_hybrid               | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_iceberg              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_dynamic              | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
| is_immutable            | VARCHAR(16777216) | COLUMN | Y     | NULL    | N           | N          | NULL  | NULL       | NULL    | NULL        | NULL           |
+-------------------------+-------------------+--------+-------+---------+-------------+------------+-------+------------+---------+-------------+----------------+
22 Row(s) produced. Time Elapsed: 0.051s
*/
--
SELECT "database_name", "schema_name", "name","kind","rows","bytes","retention_time"
FROM scratch.workspace.src_tab_show_info ;
--
SELECT "database_name", "schema_name", "name","kind","rows","bytes","retention_time"
FROM scratch.workspace.cln_tab_show_info ;
--
SELECT  table_catalog,table_schema,table_name, id, decode(id,clone_group_id, 'N', 'Y') Cloned, clone_group_id
FROM snowflake.information_schema.table_storage_metrics
WHERE table_name   in ( 'SRC_TAB', 'CLN_TAB') and
      table_schema = 'WORKSPACE';

--
-- retained_cloned_bytes = 0 because clone source table still exists
--
SELECT id, clone_group_id,active_bytes,failsafe_bytes,table_entered_failsafe,table_dropped,retained_for_clone_bytes,time_travel_bytes
FROM snowflake.information_schema.table_storage_metrics
WHERE table_name   in ( 'SRC_TAB', 'CLN_TAB') and
      table_schema = 'WORKSPACE';
--
-- drop src_tab
-- retained_cloned_bytes <> 0 if date_retention_period >1
--
drop table scratch.workspace.src_tab;
--
SELECT id, clone_group_id,active_bytes,failsafe_bytes,table_entered_failsafe,table_dropped,retained_for_clone_bytes,time_travel_bytes
FROM snowflake.information_schema.table_storage_metrics
WHERE table_name   in ( 'SRC_TAB', 'CLN_TAB') and
      table_schema = 'WORKSPACE';
--
-- insert records into cloned table
--
insert into  CLN_TAB values
(1),
(2),
(3),
(4);
--
SELECT id, clone_group_id,active_bytes,failsafe_bytes,table_entered_failsafe,table_dropped,retained_for_clone_bytes,time_travel_bytes
FROM snowflake.information_schema.table_storage_metrics
WHERE table_name   in ( 'SRC_TAB', 'CLN_TAB') and
      table_schema = 'WORKSPACE';
--



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Q. What is ZCC ?
=================
1. ZCC is a way to clone an existing table using the metadata of existing table.

Q. What are the characteristics of ZCC table ?
==============================================
1. After creation, ZCC table does not occupy any storage.
2. ZCC table continues to share metadata with its parent table.
3. When data is stored in ZCC table, only new data will occupy storage 
4. When parent table is dropped, ZCC table will continue to exist.
5. When ZCC table is dropped, the parent table remains unaffected.
6. Time travel retention days can be defined for ZCC table.
7. After ZCC is completed, any new data stored in parent table will not be seen in cloned table.
8. ZCC is quick because it does not involve copying any data.


Source Table                      Cloned Table
MP-1<------------------------------ MP-1                            
MP-2<-------------------------------MP-2
MP-3<-------------------------------MP-3
MP-4 (new MP)                       MP-4 (new MP) 
MP-5 ("" )                          MP-5 ("")
MP-5 ("" )                          MP-6 ("")
                                    MP-1 ( modified)

Q. What happens when records are added or deleted from parent table after the clone ?
=====================================================================================
1. It only affects parent table
2. The cloned table remains unaffected.

Q. What happens when records are added or deleted from cloneed table ?
=======================================================================
1. It only affects cloned table
1. The parent table remains unaffected.

Q. What happens to time travel retention period of parent table ?
==================================================================


ZCC Table Creation Full Syntax
==============================

CREATE [ OR REPLACE ] { DATABASE | SCHEMA } [ IF NOT EXISTS ] <object_name>
  CLONE <source_object_name>
    [ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]
    [ IGNORE TABLES WITH INSUFFICIENT DATA RETENTION ]
    [ IGNORE HYBRID TABLES ]
  ...


CREATE [ OR REPLACE ] TABLE [ IF NOT EXISTS ] <object_name>
  CLONE <source_object_name>
    [ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]
  ...


CREATE [ OR REPLACE ] DYNAMIC TABLE <name>
  CLONE <source_dynamic_table>
    [ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]
  [
    TARGET_LAG = { '<num> { seconds | minutes | hours | days }' | DOWNSTREAM }
    WAREHOUSE = <warehouse_name>
  ]


CREATE [ OR REPLACE ] EVENT TABLE <name>
  CLONE <source_event_table>
    [ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]


CREATE [ OR REPLACE ] ICEBERG TABLE [ IF NOT EXISTS ] <name>
  CLONE <source_iceberg_table>
    [ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]
    [ COPY GRANTS ]
    ...

CREATE [ OR REPLACE ] DATABASE ROLE [ IF NOT EXISTS ] <database_role_name>
  CLONE <source_database_role_name>

Time Travel parameters
=======================

{ AT | BEFORE } ( { TIMESTAMP => timestamp | OFFSET => time_difference | STATEMENT => id } )
The AT | BEFORE clause accepts one of the following parameters:

TIMESTAMP => timestamp
Specifies an exact date and time to use for Time Travel. The value must be explicitly cast to a TIMESTAMP, TIMESTAMP_LTZ, TIMESTAMP_NTZ, or TIMESTAMP_TZ data type.

If no explicit cast is specified, the timestamp in the AT clause is treated as a timestamp with the UTC time zone (equivalent to TIMESTAMP_NTZ). Using the TIMESTAMP data type for an explicit cast may also result in the value being treated as a TIMESTAMP_NTZ value. For details, see Date & time data types.

OFFSET => time_difference
Specifies the difference in seconds from the current time to use for Time Travel, in the form -N where N can be an integer or arithmetic expression (e.g. -120 is 120 seconds, -30*60 is 1800 seconds or 30 minutes).

STATEMENT => id
Specifies the query ID of a statement to use as the reference point for Time Travel. This parameter supports any statement of one of the following types:

DML (e.g. INSERT, UPDATE, DELETE)

TCL (BEGIN, COMMIT transaction)

SELECT
The query ID must reference a query that has been executed within the last 14 days. 
If the query ID references a query over 14 days old, the following error is returned:

Error: statement <query_id> not found
To work around this limitation, use the timestamp for the referenced query.

IGNORE TABLES WITH INSUFFICIENT DATA RETENTION
==============================================
Ignore tables that no longer have historical data available in Time Travel to clone. If the time in the past specified in the AT | BEFORE clause is beyond the data retention period for any child table in a database or schema, skip the cloning operation for the child table. For more information, see Child Objects and Data Retention Time.

Hybrid tables parameters
========================
IGNORE HYBRID TABLES
Ignore hybrid tables when cloning a database or schema. The cloned database or schema includes other objects but skips hybrid tables. For more information, see Clone databases that contain hybrid tables.

Access control requirements

Additional rules that apply to cloning objects
==============================================

Metadata
========
1. An object clone inherits the name and structure of the source object current at the time the CREATE <object> CLONE statement is executed or 
   at a specified time/point in the past using Time Travel. 

2. An object clone inherits any other metadata, such as comments or table clustering keys, that is current in the source object at the time the statement
   is executed, regardless of whether Time Travel is used.

Child objects
=============
1. A database or schema clone includes all child objects active at the time the statement is executed or at the specified time/point in the past. 

2. A snapshot of the table data represents the state of the source data when the statement is executed or at the specified time/point in the past.

3. Child objects inherit the name and structure of the source child objects at the time the statement is executed.

Not cloned
===========
1. Cloning a database or schema does not clone objects of the following types in the database or schema:

  - External tables
  - Internal (Snowflake) stages
  - Hybrid tables can be cloned for databases but not for schemas.

Pipes
=====
1. A database or schema clone includes only pipe objects that reference external (Amazon S3, Google Cloud Storage, or Microsoft Azure) stages;
   internal (Snowflake) pipes are not cloned.

2. The default state of a pipe clone is as follows:

   When AUTO_INGEST = FALSE, a cloned pipe is paused by default.

   When AUTO_INGEST = TRUE, a cloned pipe is set to the STOPPED_CLONED state.
                      In this state, pipes do not accumulate event notifications as a result of newly staged files.
                      When a pipe is explicitly resumed, it only processes data files triggered as a result of new event notifications.

3. A pipe clone in either state can be resumed by executing an ALTER PIPE … RESUME statement.

Tags
====
Cloning a database or schema affects tags in that database or schema as follows:

Tag associations in the source object (e.g. table) are maintained in the cloned objects.

For a database or a schema:

The tags stored in that database or schema are also cloned.

When a database or schema is cloned, tags that reside in that schema or database are also cloned.

If a table or view exists in the source schema/database and has references to tags in the same schema or database, the cloned table or view is mapped to the corresponding cloned tag (in the target schema/database) instead of the tag in the source schema or database.

Java UDF
=========
A Java UDF can be cloned when the database or schema containing the Java UDF is cloned. To be cloned, the Java UDF must meet certain conditions. For more information, see Limitations on cloning.

Data metric functions
=====================

Cloning does not result in DMF assignments on the target object. If you clone a database or schema that contains DMFs, the DMFs are cloned to the target database or schema.

Table data
===========

1. When cloning a database, schema, or table, a snapshot of the data in each table is taken and made available to the clone.

2. The snapshot represents the state of the source data either at the time the statement is executed or at the specified time/point in the past (using Time Travel).

Object references
=================

1. Objects such as views, streams, and tasks include object references in their definition. For example:

2. A view contains a stored query that includes table references.

3. A stream points to a source table.

4. A task or alert calls a stored procedure or executes a SQL statement that references other objects.

When one of these objects is cloned, either in a cloned database or schema or as an individual object, for those object types that support cloning, the clone inherits references to other objects from the definition of the source object. For example, a clone of a view inherits the stored query from the source view, including the table references in the query.

Pay close attention to whether any object names in the definition of a source object are fully or partially qualified. A fully-qualified name includes the database and schema names. Any clone of the source object includes these parts in its own definition.

For example:

-- Create a schema to serve as the source for a cloned schema.
CREATE SCHEMA source;

-- Create a table.
CREATE TABLE mytable (col1 string, col2 string);

-- Create a view that references the table with a fully-qualified name.
CREATE VIEW myview AS SELECT col1 FROM source.mytable;

-- Retrieve the DDL for the source schema.
SELECT GET_DDL ('schema', 'source', true);
+--------------------------------------------------------------------------+
| GET_DDL('SCHEMA', 'SOURCE', TRUE)                                        |
|--------------------------------------------------------------------------|
| create or replace schema MPETERS_DB.SOURCE;                              |
|                                                                          |
| create or replace TABLE MPETERS_DB.SOURCE.MYTABLE (                      |
|   COL1 VARCHAR(16777216),                                                |
|   COL2 VARCHAR(16777216)                                                 |
| );                                                                       |
|                                                                          |
| create view MPETERS_DB.SOURCE.MYVIEW as select col1 from SOURCE.MYTABLE; |
|                                                                          |
+--------------------------------------------------------------------------+
-- Clone the source schema.
CREATE SCHEMA source_clone CLONE source;

-- Retrieve the DDL for the clone of the source schema.
-- The clone of the view references the source table with the same fully-qualified name
-- as in the view in the source schema.
SELECT GET_DDL ('schema', 'source_clone', true);
+--------------------------------------------------------------------------------+
| GET_DDL('SCHEMA', 'SOURCE_CLONE', TRUE)                                        |
|--------------------------------------------------------------------------------|
| create or replace schema MPETERS_DB.SOURCE_CLONE;                              |
|                                                                                |
| create or replace TABLE MPETERS_DB.SOURCE_CLONE.MYTABLE (                      |
|   COL1 VARCHAR(16777216),                                                      |
|   COL2 VARCHAR(16777216)                                                       |
| );                                                                             |
|                                                                                |
| create view MPETERS_DB.SOURCE_CLONE.MYVIEW as select col1 from SOURCE.MYTABLE; |
|                                                                                |
+--------------------------------------------------------------------------------+
If you intend to point a view to tables with the same names in other databases or schemas, we suggest creating a new view rather than cloning an existing view. This guidance also pertains to other objects that reference objects in their definition.

Note

Certain limitations apply to cloning operations. For example, DDL statements that affect the source object during a cloning operation can alter the outcome or cause errors.

Cloning is not instantaneous, particularly for large objects (databases, schemas, tables), and does not lock the object being cloned. As such, a clone does not reflect any DML statements applied to table data, if applicable, while the cloning operation is still running.

For more information about this and other use cases that might affect your cloning operations, see Cloning considerations.

Notes for cloning with Time Travel
===================================

The AT | BEFORE clause clones a database, schema, or table as of a specified time in the past or based on a specified SQL statement:

The AT keyword specifies that the request is inclusive of any changes made by a statement or transaction with timestamp equal to the specified parameter.

The BEFORE keyword specifies that the request refers to a point immediately preceding the specified parameter.

Cloning using STATEMENT is equivalent to using TIMESTAMP with a value equal to the recorded execution time of the SQL statement (or its enclosing transaction), as identified by the specified statement ID.

An error is returned if:

The object being cloned did not exist at the point in the past specified in the AT | BEFORE clause.

The historical data required to clone the object or any of its child objects (for example, tables in cloned schemas or database) has been purged.

As a workaround for child objects that have been purged from Time Travel, use the IGNORE TABLES WITH INSUFFICIENT DATA RETENTION parameter of the CREATE <object> … CLONE command. For more information, see Child objects and data retention time.

If any child object in a cloned database or schema did not exist at the point in the past specified in the AT | BEFORE clause, the child object is not cloned.

If you don’t specify a point in time, the clone defaults to the state of the object as of now (the CURRENT_TIMESTAMP value).

For more information, see Understanding & using Time Travel.

Troubleshoot cloning objects using Time Travel
==============================================
The following scenarios can help you troubleshoot issues that can occur when cloning an object using Time Travel.

Error 

000707 (02000): Time travel data is not available for <object_type>
<object_name>. The requested time is either beyond the allowed time
travel period or before the object creation time.
This error can be returned for the following reasons:

Cause
The time in the past specified by the AT | BEFORE clause is beyond the data retention period for the object.

Solution
Verify the data retention period for the object using the appropriate SHOW <objects> command and the retention_time column. Update the CREATE <object> … CLONE statement to use a time in the past that is within the data retention period for the object.

Cause
The cloning operation for a database or schema fails if the historical data for any child object has moved out of Time Travel.

Solution
To skip child tables that no longer have historical data available in Time Travel, execute the cloning statement using the IGNORE TABLES WITH INSUFFICIENT DATA RETENTION parameter to skip these tables.

Cause
In some cases, this is caused by using a string where a timestamp is expected.

Solution
Cast the string to a timestamp.

... AT(TIMESTAMP => '2023-12-31 12:00:00')               -- fails
... AT(TIMESTAMP => '2023-12-31 12:00:00'::TIMESTAMP)    -- succeeds
Copy
Examples



EOF
#
clear
echo -n "View zero copy clone primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#  
#  
########################################################################################
# Name     : create_zcc_table
# Overview : The function creates zcc table.
# Notes :
#########################################################################################
create_zcc_table ()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- create parent of clone table
--
CREATE or REPLACE table parent  ( id number(4), desc varchar(30), source varchar(20));
insert into parent values 
(1, 'Desc-1', 'parent'),
(2, 'Desc-2', 'parent'),
(3, 'Desc-3', 'parent');
--
-- create zcc table
--
CREATE  OR REPLACE  TABLE cloned_parent
CLONE parent ;

EOF2

snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#  
#  
#  
########################################################################################
# Name     : monitor_zcc_table
# Overview : The function monitors zcc table .
# Notes :
#########################################################################################
monitor_zcc_table()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
-- source and cloned table are identical just after cloned
--
SELECT *
FROM parent;
--
SELECT *
FROM cloned_parent;
--
-- modify parent table
--
insert into parent values 
(4, 'Desc-1', 'parent'),
(5, 'Desc-2', 'parent'),
(6, 'Desc-3', 'parent');
--
-- modify cloned table
--
insert into cloned_parent values 
(4, 'Desc-1', 'cloned_parent'),
(5, 'Desc-2', 'cloned_parent'),
(6, 'Desc-3', 'cloned_parent');
--
SELECT *
FROM parent;
--
-- new records are not visible in cloned table
--
SELECT *
FROM cloned_parent;
--
-- retained_cloned_bytes for cloned table  = 0 because clone source table still exists
--
SELECT id, clone_group_id,active_bytes,failsafe_bytes,table_entered_failsafe,table_dropped,retained_for_clone_bytes,time_travel_bytes
FROM snowflake.account_usage.table_storage_metrics
WHERE table_name   in ( 'PARENT', 'CLONED_PARENT') and
      deleted = FALSE;
--
-- delete from source table
-- retained_cloned_bytes <> 0 if date_retention_period >1
--
delete
from parent;
--
SELECT id, clone_group_id,active_bytes,failsafe_bytes,table_entered_failsafe,table_dropped,retained_for_clone_bytes,time_travel_bytes
FROM snowflake.account_usage.table_storage_metrics
WHERE table_name   in ( 'PARENT', 'CLONED_PARENT') and
      deleted = FALSE;
--
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
########################################################################################
# Name     : query_zcc_metadata
# Overview : The function queries zcc metadata.
# Notes :
#########################################################################################
query_zcc_metadata()
{
#
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
SELECT *
FROM parent;
--
EOF2
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Log Details"  > ${REPORT_FILE}
echo "                ==========="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the log;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
#
}
#
#
#
#
#########################################################################################
# Name     : display_zero_copy_clone_menu
# Overview : The function displaya zero copy clone menu.
#
#########################################################################################
display_zero_copy_clone_menu()
{
MENU_NAME=zccl

while true
do
clear

echo  -n "
################################
#    Zero Copy Clone Menu      #
#                              #
#   5. Show ZCC Primer         #
#  10. List All Cloned Tables  #
#  15. Create ZCC Table        #
#  20. Monitor ZCC Table       # 
#  25. Query ZCC Metadata      #
#                              #
#  98. Root Menu               # 
#  99. Exit                    # 
#                              #
#  ZCC=Zero Copy Clone         #
################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 

done
#
#
}
#
#
#
#########################################################################################
# Name     : show_performance_optimisation_primer
# Overview : The function shows the performance optimisation primer.
#
#########################################################################################
show_performance_optimisation_primer()
{
#
#{
#
cat <<EOF  >  ${TEMP_FILE_1}

                                Performance Optimisation Primer
                                ===============================

Q. What is performance optimisation ?
=====================================
1. Performance optimisation is a methodical approach to :
     - address the slow running queries
     - address slow data load
     - address any poorly performing DML and DCL



Q. What are the overall approaches to performance optimisation?
===============================================================
1. Tune  Query
2. Tune  warehouse
3. Tune  Storage

Q. What are the steps involved in query tunning ?
=================================================
1. Investigate Query queuing
2. Investigate disk spilling
3. Investigate row explosion
4. Investifate pruning
5. Investigate Join Order
6. Investigate result caching

1. What are the steps involved in the investigation of query queing ?
====================================================================
2. You can not determine query queuing from the query profile because, it is a runtime
    phenomenon.

3. Several factors can result in a query being queued. 

4. To find out which one applies, the  INFORMATION_SCHEMA.QUERY_HISTORY can be used.

5. This view will show queuing time in several different categories:
 
   -  QUEUED_OVERLOAD_TIME: This is the time (in milliseconds) the query spent in the warehouse queue, due to the warehouse being overloaded
                             by the current query workload.
  
   -  QUEUED_PROVISIONING_TIME: The time (in milliseconds) a query waits in the warehouse queue for resources to be allocated, due to warehouse 
                                creation, resuming, or resizing.

   -  QUEUED_REPAIR_TIME: The duration (in milliseconds) that a query spends in the warehouse queue waiting for compute resources to be repaired. 
                          This situation arises when a faulty server is automatically replaced by a healthy one.
                          This is a rare condition that can happen in the case of hardware failures.

Q. What are the questions that we need to ask while investigating the queuing?
==============================================================================
1. Find out the current concurrency level, MAX_CONCURRENCY_LEVEL 
2. Reduce the concurrency level by 25%.
3. Are the queries still being queued ?
4. If no, problem solved
5. If yes and we do not want to reduce the concurrency any further,
   consider, switching to multi-clustered warehouse.


Q. How to monitor queuing conditions ?
======================================
1.  When queries spend a significant time queuing, the overall workload submitted to the warehouse takes longer to execute.
    This can be monitored by using the graph in the web interface 
    Go to the Warehouses section of Snowflake UI and click on the Warehouse which is showing performance issues.

Q. What is the most command condition for queuing ?
===================================================
1. The most common condition for  queuing  is due to load.
2. When the warehouse is already busy, and executing another query would lead to performance degradation, the query is queued and 
   waits until the necessary resources become available.

Q. How do we determine the current load?
========================================
1.  The current resource consumption (RAM and CPU)<-- current warehouse size
2.  The number of queries already executing.


Q. How to see the number of queries that are being allowed to run concurrently ?
================================================================================ 
1. The number of queries that can execute in parallel on a warehouse is configurable by setting the parameter MAX_CONCURRENCY_LEVEL.

2. It is generally not recommended to increase this parameter, as an increased number of queries executing in parallel 
   can lead to decreased performance.


Q. What are the steps involved in the investigating of disk spilling ?
======================================================================

Issue
Sometimes the query profile shows the information on Spilling (Bytes spilled to local/remote storage) similar to the below example:

User-added image
This is usually related to noticeably decreased performance.
 

Cause
What is disk spilling? When Snowflake warehouse cannot fit an operation in memory, it starts spilling data first to the local disk of a warehouse, and then to remote storage.

In such a case, Snowflake first tries to temporarily store the data on the warehouse local disk. As this means extra IO operations, any query that requires spilling will take longer than a similar query running on similar data that is capable to fit the operations in memory.

Also, if the local disk is not sufficient to fit the spilled data, Snowflake further tries to write to the remote cloud storage, which will be shown in the query profile as "Bytes spilled to remote storage".

User-added image
A query spilling bytes to the remote storage will notice even further performance degradation.

Solution
The spilling can't always be avoided, especially for large batches of data, but it can be decreased by:

Reviewing the query for query optimization especially if it is a new query.
Reducing the amount of data processed. For example, by trying to improve partition pruning, or projecting only the columns that are needed in the output.
Decreasing the number of parallel queries running in the warehouse.
Trying to split the processing into several steps (for example by replacing the CTEs with temporary tables).
Using a larger warehouse. This effectively means more memory and more local disk space.
 
Q. What are the steps involved in the investigating of row explosion ?
======================================================================
Solution
A common cause of slow queries is the joins that produce more rows than the query author anticipated. This is often referred to as a “row explosion”.
 

An easy way to recognize these is to check the query profile for join operators that display more rows in the output than in either of the input tables. An example is shown below:


In this case, the join receives 10k rows from one side and 5 million rows from the other side. But it is generating almost 9 billion rows.
 

There are of course situations where this is what the query author wants. In many cases, however, it is the result of an erroneous join condition. Usually, this happens because of a high number of duplicates in the columns that are present in the join condition. An extreme case is if the join condition is missing completely.  In that case, the number of rows produced will be equal to the product of the number of rows on both sides.
 

When too many rows are produced, query performance can degrade due to operators running out of memory and spilling to disk. To remedy this, please verify that you intended for the join output you are seeing. Whilst in some cases it is unavoidable, mostly it's just an error in the way the query is written.


Q. What are the steps involved in the investigating of partition pruning ?
==========================================================================
Solution
Snowflake makes extensive use of pruning to reduce the amount of data that has to be read from storage. In summary, this means that a query like the following

SELECT 
   SUM(X) 
FROM 
   T1 
WHERE 
   Y=42;
will not read columns X and Y completely from storage but will make use of the predicate Y=42 and limit the table scan to the subset of all partitions that can potentially match this condition. For more details, see Understanding Snowflake Table Structures.

In the Snowflake query profile, this can be seen by clicking on a table scan operator and looking at the details on the right-hand side:
User-added image

In this example, a third of all partitions were scanned.

In some corner cases, this does not work as well as expected. There are usually good reasons why the pruning cannot work, but it is worth understanding it as it may yield possible improvements to the way a query is written.

Unsatisfactory pruning can be recognized from patterns like the following in the query profile:
 

User-added image

In this situation, we see that there is a filter immediately after the table scan removed almost all of the rows read from disk. This means that the performance could be dramatically improved by more efficient pruning.

To improve pruning, the general recommendation is to consider whether clustering can be improved. See the following articles and documents for more details:

Case Study: How Clustering Can Improve Your Query Performance
Understanding Micro-partitions and Data Clustering



Q. What are the steps involved in the investigating of join orders ?
====================================================================
Solution
In some rare situations, it is not possible for the optimizer to identify the join ordering that would result in the fastest execution. In these cases, it may be desirable to exercise more control over this aspect of query execution. 


The solution for this is to use temporary tables. For example, consider a query like the following:

SELECT 
   X,
   Y 
FROM 
   T1 
   INNER JOIN T2 
      USING (Z)
   INNER JOIN T3 
      USING (W);

Looking at the query profile, you notice that Snowflake joins T2 and T3 first, and then joins the results to T1. Using your additional knowledge of the data, you determine that this is not the fastest approach. In that case, you can write the following:

CREATE TEMPORARY TABLE TEMP1 AS
SELECT 
   X,
   Y,
   Z,
   W
FROM 
   T1
   INNER JOIN T2 
      USING (Z);

SELECT 
  X, 
  Y
FROM 
   TEMP1
   INNER JOIN T3 
      USING (W);
This approach guarantees that the joins are executed in your preferred order.
 

When to use this solution
The typical situation where this may make sense is when the query profile shows both of the following conditions for a JOIN operator:

A large number of rows on the left hand input, and a much lower number on the right hand.
A significant percentage of the overall query execution time is spent in the join operator.
 
Limitations
Temporary tables are persisted to S3. So there is some additional overhead. But note that in the case of large joins, they might have spilled to S3 as well.

Snowflake does not expose functionality like optimizer hints that is sometimes found in other databases to control the order in which joins are performed. In general, the SQL query optimizer chooses the correct order for joining tables. If you encounter a situation where it doesn’t, please open a Snowflake Support ticket so that we can investigate and improve this behavior.


Q. What are the steps involved in the investigating of result caching ?
=======================================================================
Solution
Description
Snowflake caches and persists the query results for every executed query. This can be used to great effect to dramatically reduce the time it takes to get an answer.

Typically, query results are reused if all of the following conditions are met:

The user executing the query has the necessary access privileges for all the tables used in the query.
The new query syntactically matches the previously-executed query.
The table data contributing to the query result has not changed.
The persisted result for the previous query is still available.
Any configuration options that affect how the result was produced have not changed.
The query does not include functions that must be evaluated at execution (e.g. CURRENT_TIMESTAMP()).
The table’s micro-partitions have not changed (e.g. been re-clustered or consolidated) due to changes to other data in the table.
To verify whether a query made use of the result cache, check the query profile in the Snowflake UI. It will show a node like the following:
User-added image
When working with cached results, the following functions are useful:

RESULT_SCAN, to access the cached result directly: https://docs.snowflake.net/manuals/sql-reference/functions/result_scan.html       
Example: Run a complex query, and then to access its results again, execute the following query:

select * from table(result_scan(last_query_id())) 

This allows you to retrieve the results again even if the conditions above not satisfied. However in this case, it’s not happening automatically, but rather we need to explicitly state that we want the results of the last query.
DESC RESULT, to get the columns available in a cached result: https://docs.snowflake.net/manuals/sql-reference/sql/desc-result.html






1. Examine query profile
2. Examine followings in the profile:
          - total number of partitions
          - number of partitions scanned
          - no of bytes spilled to local storage
          - no of bytes spilled to remote storage
          - identify most expensive node by examining the execution time






Q. How to use partitions information ?
======================================
1. If number of partitions scanned is equal to total number of partitions, this means
   no partition pruning has taken place. 

2. Examine the where clause of the query. If the query does not have a where clause, snowflake
   will scan all the partitions.

3. If the query has a where clause but filtered column(s) are not clustered. snowflake will scan all the partitions.






Q. What are the steps involved in warehouse tunning ?
=====================================================

Q. What are the steps involved in storage tunning ?
===================================================





Q. What is the most important performance optimisation ?
========================================================
1. Slow running SQL queries


                            SQL Query Optimisation
                            ======================

Q. What is SQL query optimisation ?
===================================
1. It is a methodical approach to address slow running SQL queries.

Q. Why does SQL query optimisation matter ?
===========================================
1. It matters for following two reasons:
            - slow running quedry takes longer to return results
            - slow running query increases the cost of running the query


Q. What are the approaches to SQL query optimisation ?
======================================================

1. Choosing the proper virtual warehouse size

2. Using caching and optimization of auto-suspend configurations

3. Performing data clustering and micro-partitioning

4. Using Snowflake Query Acceleration

5. Using Materialized Views

6. Utilizing the Query Profile tool

7. Using the Snowflake Search optimization service

FAQs
=====
Q. Why does Snowflake performance tuning matter?
================================================
1. Snowflake performance tuning is essential because it can deliver faster query results and help save costs by optimizing resource usage.

Q. What is query optimization in Snowflake?
===========================================
1. Query optimization in Snowflake refers to the process of optimizing queries to achieve optimal performance, minimize resource usage, 
   and reduce data warehouse costs. It involves employing various techniques and practices to streamline query execution.

Q. How does Snowflake execute queries?
======================================
1. Snowflake executes queries by distributing the workload across multiple nodes in a Virtual Warehouse, leveraging parallel processing and
   query optimization techniques.

Q. What is Snowflake caching, and how does it improve query performance?
===--===================================================================
1. Snowflake caching involves storing query results in caches at the Cloud Services and Data Warehouses layers. 
2. Caching improves query performance by reducing the need for remote storage access.

Q. How does partition pruning work in Snowflake?
================================================
1. Snowflake uses partition pruning by utilizing metadata statistics to narrow down the search to specific micro-partitions, 
   significantly improving query performance on large tables.

Q. How can I identify and improve queries with poor performance in Snowflake?
=============================================================================
1. Monitoring query history, examining statistics such as partitions scanned and rows fetched, and identifying areas for improvement 
  can help optimize queries in Snowflake.

Q. What is the impact of warehouse size on query performance in Snowflake?
==========================================================================
1. Increasing warehouse size in Snowflake maximizes throughput by distributing the workload across more nodes, but it doesn't directly increase query speed.

Q. Why is a Snowflake query slow?
=================================
1. Generally, Snowflake executes queries quickly without requiring any intervention.

2. However, a slow query is typically indicative of a mistake in the way the query is written.




EOF
#}
#
clear
echo -n "View time travel and failsafe primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
#
#########################################################################################
# Name     : show_longest_running_queries
# Overview : The function displaya longewst running queries
#
#########################################################################################
show_longest_running_queries()
{
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True

SELECT
  --  query_id,
  --ROW_NUMBER() OVER(ORDER BY partitions_scanned DESC) AS query_id_int,
  start_time,
  query_text,
  database_name,
  schema_name, 
  warehouse_name,
  user_name,
  total_elapsed_time/1000 AS time_seconds
  -- partitions_scanned,
  -- partitions_total
FROM snowflake.account_usage.query_history Q
WHERE -- warehouse_name        = 'my_warehouse' AND 
     --  to_date(Q.start_time) > dateadd(day,-1,TO_DATE(CURRENT_TIMESTAMP())) and
     total_elapsed_time     > 0    and  --only get queries that actually used compute
     error_code IS NULL            and
     partitions_scanned IS NOT NULL
ORDER BY total_elapsed_time desc
LIMIT 50;
--
--
EOF2
#
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                List of Top Ten Longest Running Queries"  > ${REPORT_FILE}
echo "                ======================================="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
#########################################################################################
# Name     : show_longest_running_query_details
# Overview : The function displays longest running query details.
#
#########################################################################################
show_longest_running_query_details()
{
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True

SELECT
  query_id,
  query_text,
  total_elapsed_time/1000 AS time_seconds,
  partitions_scanned p_scanned,
  partitions_total p_total,
  percentage_scanned_from_cache psfc,
  bytes_spilled_to_local_storage bstls,
  bytes_spilled_to_remote_storage bstrs
FROM snowflake.account_usage.query_history Q
WHERE total_elapsed_time     > 0   and 
     error_code IS NULL            and
     partitions_scanned IS NOT NULL
ORDER BY total_elapsed_time desc
LIMIT 50;
--
--
EOF2
#
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                List of Top Ten Longest Running Query Details"  > ${REPORT_FILE}
echo "                ============================================="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
#
#
#
#
#
#####################################################################################################
# Name     : factors_contributing_to_poor_query_performance 
# Overview : The function shows factors that contrinute to poor sql query per4formance
# Notes    :
#
####################################################################################################
show_factors_contributing_to_poor_query_performance ()
{
#
cat <<EOF  > ${TEMP_FILE_1}

Factors Contributing To Poor Query Performance
==============================================

       - Excessive Data Scanning
       - Complex Joins and Aggregations

Excessive Data Scanning
=======================

1. The primary cause of poor query performance is scanning excessive data.
2. In Snowflake, data is fetched from a central location to the computing resources for processing. 
3. This data transfer step can be resource-intensive, often involving gigabytes or even hundreds of gigabytes of data.
4. To mitigate this issue, it’s crucial to apply date filters to your queries, thereby reducing the amount of data scanned.
4. It is recommended to narrow down the date range and add additional parameters to filter the data, especially if you are looking to explore the dataset.
5. The following query would be more efficient for exploring purposes, in particular when working with huge datasets like TB of data:

--Query 1. Filtering data

SELECT
  campaign_id,
  campaign_name,
  channel_category,
  type,
  start_date,
  end_date,
  status,
  budgeted_cost,
  actual_cost
FROM
  APPLICATIONS.SALESFORCE.CAMPAIGN 
WHERE 
  created_at >= DATEADD(day, -1, current_timestamp)

Complex Joins and Aggregations
==============================
1. Another aspect impacting query efficiency lies in the intricacies of joining tables across multiple datasets.

2. The process of joining necessitates comparing each row of one table with every row of another unless clustering exists on the join column. 

3. When formulating JOIN clauses within Snowflake, it becomes imperative to meticulously verify the presence of ON conditions.

4. The absence of these conditions could result in the execution of exorbitantly costly queries, leading to prolonged execution times
   that may culminate in failure.

5. Moreover, the inclusion of OR operators within JOIN clauses is not recommended due to their detrimental effect on query performance,
   as they tend to slow down the execution process significantly.

6. Instead, employing separate JOIN clauses with distinct conditions on subsequent lines can help maintain optimal query efficiency. 

7. Furthermore, addressing the complexity of join operations underscores the significance of strategic query planning and database schema optimization.

8. By carefully structuring join conditions and utilizing clustering techniques where applicable, organizations can streamline query execution, 
   enhance system performance, and facilitate smoother data analytics workflows. 

9. In the following SQL queries, the query 3 is much faster than the query 1.


--Query 2. JOIN clause with OR operator

SELECT
  campaign_id,
  campaign_name,
  channel_category,
  type,
  start_date,
  end_date,
  status,
  budgeted_cost,
  actual_cost
FROM
  APPLICATIONS.SALESFORCE.CAMPAIGN AS a
  LEFT JOIN APPLICATIONS.SALESFORCE.CAMPAIGN_NAME AS b
     ON a.id = b.campaign_id OR a.uuid = b.campaign_uuid

--Query 3. JOIN clause without OR operator

SELECT
  campaign_id,
  NVL(b.campaign_name, c.campaign_name) as campaign_name,
  channel_category,
  type,
  start_date,
  end_date,
  status,
  budgeted_cost,
  actual_cost
FROM
  APPLICATIONS.SALESFORCE.CAMPAIGN AS a
  LEFT JOIN APPLICATIONS.SALESFORCE.CAMPAIGN_NAME AS b
     ON a.id = b.campaign_id  
  LEFT JOIN APPLICATIONS.SALESFORCE.CAMPAIGN_NAME AS c
     ON a.uuid = b.campaign_uuid


Concurrency in the Warehouse
============================

External factors, such as concurrent queries running in the warehouse, can significantly influence query performance. When multiple queries are executed simultaneously, they compete for computing resources, potentially slowing down individual query response times. To mitigate this impact, it’s essential to implement efficient warehouse management practices. By allocating the appropriate resources and prioritizing queries based on their criticality, organizations can ensure smoother operations and optimal performance. This factor can be managed by applying a proper warehouse configuration before executing the query in Snowflake. Additionally, proactive monitoring and workload management strategies can help identify potential bottlenecks and ensure that resources are allocated effectively to meet performance requirements. By optimizing warehouse usage and workload distribution, businesses can enhance overall query performance and maintain efficient data processing operations.

Column Selection

When constructing SQL queries, it’s essential to be mindful of best practices to ensure optimal performance and maintainability. One crucial consideration is to avoid using “SELECT *”, which is widely regarded as a bad practice, especially in columnar stores like Snowflake. Instead, it’s recommended to explicitly specify only the columns that are required for the query. Fetching all columns indiscriminately from storage can lead to slower query execution due to unnecessary I/O operations. Additionally, using “SELECT *” can pose potential issues when the schema of the underlying tables changes, as it may inadvertently introduce unexpected columns into the result set. This lack of transparency regarding the result set can make query maintenance more challenging. Furthermore, fetching unnecessary columns can unnecessarily fill up the cache with data that is not needed, potentially impacting the performance of other queries that rely on cache utilization. Therefore, it’s advisable to adhere to the principle of selecting only the necessary columns to ensure efficient and predictable query execution in columnar stores. Fetching only columns of interest is always a better strategy as it improves query effectiveness. This is achieved by restricting query execution only to the columns needed for the analysis thus streamlining search engine utilization, as well as reducing resource usage (Ryan, 2023).

Indexing and Clustering

Indexing and clustering are the core optimization methods that amplify the speed of query execution and diminish the scan pattern of data in Snowflake. Creating indexes and clustering keys appropriately allows Snowflake to achieve data retrieval and processing optimization, which further contributes to the speed of query execution as well as ensures good system reactivity. As mentioned in the article, clusters were created on the columns the tables frequently join. This is based on data locality and less data movement, which leads to significantly faster query processing. Through the selective indexing and clustering tables, people will enhance the engine query processing performance of the Snowflake system and obtain the optimum performance level (George, 2023).

Function Use in Where Clauses

Snowflake has built-in mechanisms to avoid scanning irrelevant data, which can significantly improve query efficiency. For instance, when filtering data based on a specific time range, Snowflake will intelligently skip scanning data from periods outside of this range. However, it’s crucial to be mindful of how functions are applied within the query. Applying a function directly to a column can impede Snowflake’s optimization efforts, preventing it from efficiently skipping unnecessary data. In such scenarios, it’s advisable to prioritize modifying the compared values instead of applying functions directly to columns. This results in queries better leveraging Snowflake’s optimization features, thereby leading to improved performance and reduced query execution times.

--Query 4. Funtion use in where clause
SELECT
  campaign_id,
  campaign_name,
  start_date,
  end_date
FROM
  APPLICATIONS.SALESFORCE.CAMPAIGN  
WHERE 1 = 1
--option 1
❌  AND TO_DATE(start_datetime) BETWEEN '2023-01-01' AND '2023-12-31'
--option 2
✅  AND start_datetime >= '2023-01-01'::TIMESTAMP AND start_datetime < DATEADD(DAY, 1, '2023-12-31'::TIMESTAMP)   

--option 1     
❌  AND SUBSTR(campaign_name, 1, 5) = 'Bingo'
--option 2
✅  AND campaign_name LIKE 'Bingo%’
Conclusion

In conclusion, optimizing query performance in Snowflake is paramount for organizations striving to derive timely insights and maximize resource utilization in today’s data-driven landscape. By implementing advanced SQL techniques and adhering to best practices outlined in this article, Snowflake users can optimize their query performance and derive optimal results from Snowflake. From applying date filters to reduce data scanning to utilizing separate JOIN clauses for optimal efficiency, each optimization strategy contributes to streamlining query execution and enhancing system performance. Additionally, selective indexing and clustering of tables further amplify query processing speed, ensuring an optimum performance level.


EOF
#
#
echo -n "View the document;Press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
}
#
#
#
##############################################################################################################
# Name     :optimizing_warehouses_for_performance
# Overview : The function shows how to optimise warehouse for performance.
# Notes    :
###############################################################################################################
optimizing_warehouses_for_performance()
{
#
cat <<EOF   > ${TEMP_FILE_1}

                   Optimizing Warehouse for Performance
                   ====================================

1. In the Snowflake architecture, virtual warehouses provide the computing power that is required to execute queries.
2. Fine-tuning the compute resources provided by a warehouse can improve the performance of a query or set of queries.

3.Warehouse-related strategies are just one way to boost the performance of queries.
4. For performance strategies involving how data is stored, refer to Optimizing storage for performance.

Strategy                         Description
Reduce queues                    Minimizing queuing can improve performance because the time between submitting a query and getting its results is longer when the query must wait in a queue before starting.

Resolve memory spillage           Adjusting the available memory of a warehouse can improve performance because a query runs substantially slower when a warehouse runs out of memory, which results in bytes “spilling” onto storage.

Increase warehouse size         The larger a warehouse, the more compute resources are available to execute a query or set of queries.

Try query acceleration              The query acceleration service offloads portions of query processing to serverless compute resources, which speeds up the processing of a query while reducing its demand on the warehouse’s compute resources.

Optimize the warehouse cache    Query performance improves if a query can read from the warehouse’s cache instead of from tables.

Limit concurrently running queries   Limiting the number of queries that are running concurrently in a warehouse can improve performance because there are fewer queries putting demands on the warehouse’s resources.

Tip

Optimizing a warehouse for query performance is more straightforward when the warehouse runs similar workloads. 
For example, if a warehouse runs significantly different queries, the cost of a performance enhancement might be wasted on a query that does not
 benefit from the optimization.

EOF
#
#
echo -n "View the document;Press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
#
}
#
#
#
##############################################################################################################
# Name     :performance_improving_steps
# Overview :The function shows all steps required to improve performance.
# Notes    :
###############################################################################################################
show_performance_improving_steps()
{
#
cat <<EOF   > ${TEMP_FILE_1}

                   Performance Improving Steps
                   ===========================
1. Identify the query/task/load
2. Review the query against the guidelines 
3. Identify warehouse running the query
4. Optimise warehouse performasnce following the guidelines
5. Optimise storage performance following the guidelines

Identify the query/task/load
============================
1. Query snowflake.account_usage.query_history view to identify the query looking at the elapsed time

Review the query against the guidelines 
========================================
Excessive Data Scanning
+++++++++++++++++++++++
Q. What is excessive data scaning ?
-----------------------------------
TPR=Total Number of Partitiopns
PS = Total number of partitions scanned

If PS is more than 10% og TPR, this needs a review.


Mitigating Excessive Data Scanning
===================================
1. Review WHERE clause of query
2. Remove any unnessecary data  by adding additional filters


Complex Joins and Aggregations
==============================
1. Are the tables in join clustered on join keys ?
2. If not , consider doing this. 


Concurrency in the Warehouse
============================


Column Selection
=================
1. Drop  columns from the select, that are not required.
2. Substiture SELECT * with SELECT with specific column names

Indexing and Clustering
========================
1. If the table in question is a hybrid table, create indexes on columns
   that are used in where clause.


Identify warehouse running the query
====================================
1. Query snowflake.account_usage.query_history view to identify the warehouse that is running 
   the query of interest.


Optimise warehouse performasnce following the guidelines
========================================================
Strategy                         Description
Reduce queues                    Minimizing queuing can improve performance because the time between submitting a query and getting its results
                                 is longer when the query must wait in a queue before starting.

Resolve memory spillage          Adjusting the available memory of a warehouse can improve performance because a query runs substantially slower
                                 when a warehouse runs out of memory, which results in bytes “spilling” onto storage.

Increase warehouse size          The larger a warehouse, the more compute resources are available to execute a query or set of queries.

Try query acceleration           The query acceleration service offloads portions of query processing to serverless compute resources,
                                 which speeds up the processing of a query while reducing its demand on the warehouse’s compute resources.

Optimize the warehouse cache     Query performance improves if a query can read from the warehouse’s cache instead of from tables.

Limit concurrently running       Limiting the number of queries that are running concurrently in a warehouse can improve performance because there are
running queries                  fewer queries putting demands on the warehouse’s resources.



Optimise storage performance following the guidelines
=====================================================
1. Automatic clustering
2. Search optimisation service
3. Materialized view


EOF
#
#
echo -n "View the document;Press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
#
#
}
#
#
#########################################################################################
# Name     : explain_plan
# Overview : The function is used to perform explain plan.
#
#########################################################################################
explain_plan()
{
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
create or replace table dept ( dno number(2), dname varchar(30), dloc varchar(30) );
insert into dept values
(10, 'Finance', 'London'),
(20, 'Accounts','London'),
(30, 'Sales'   ,'Leeds'),
(40, 'Marketing', 'Manchester'),
(50, 'IT', 'Glasgow');
--
--
create or replace table empp ( empno number(4), fname varchar(20), lname varchar(20), gender varchar(1), dob_ddmmyyyy varchar(8), mobile  varchar(11), dno number(2));
--
insert into empp values
(1000,'Arif','Zaman','M','12061957','07836543200',10),
(2000,'James','Bond','M','11051967','07835335011',20);
--
--
EXPLAIN using  TABULAR
SELECT  empno, fname,lname, gender, e.dno, d.dname, d.dloc
FROM  dept d,
      empp e
WHERE  e.dno = d.dno ;
--
--
/*
SELECT system\$Explain_json_to_text(
              system\$explain_plan_json(last_query_id() )) "Query Plan" ;
*/
--
--
EOF2
#
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Xplain Plan Report"  > ${REPORT_FILE}
echo "                =================="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
###################################################################################################
# Name     :analyse_query_with_get_query_operator_stats 
# Overview : The function analyses query with the function called get_query_operator_stats.
# Notes    :
####################################################################################################
analyse_query_with_get_query_operator_stats ()
{
create_outer_wrapper_script()
{
cat  <<EOF1  > ${OUTER_WRAPPER_SCRIPT}
#
cat  <<EOF2  > ${SQL_SCRIPT}                                               
!set echo=True
--
with query_stats as(
select
   QUERY_ID,
   STEP_ID,
   OPERATOR_ID,
   PARENT_OPERATOR_ID,
   OPERATOR_TYPE,
   OPERATOR_STATISTICS,
   EXECUTION_TIME_BREAKDOWN,
   OPERATOR_ATTRIBUTES,
   EXECUTION_TIME_BREAKDOWN:overall_percentage::float as OPERATOR_EXECUTION_TIME,
   OPERATOR_STATISTICS:output_rows output_rows,
   OPERATOR_STATISTICS:input_rows input_rows,
   CASE WHEN operator_statistics:input_rows>0 THEN operator_statistics:output_rows / operator_statistics:input_rows ELSE 0 END as row_multiple,

   /* look for queries too large to fit into memory */
   OPERATOR_STATISTICS:spilling:bytes_spilled_local_storage bytes_spilled_local,
   OPERATOR_STATISTICS:spilling:bytes_spilled_remote_storage bytes_spilled_remote,
  
   operator_statistics:io:percentage_scanned_from_cache::float percentage_scanned_from_cache,

   operator_attributes:table_name::string tablename,
   OPERATOR_STATISTICS:pruning:partitions_scanned partitions_scanned,
   OPERATOR_STATISTICS:pruning:partitions_total partitions_total,
   OPERATOR_STATISTICS:pruning:partitions_scanned/OPERATOR_STATISTICS:pruning:partitions_total::float as partition_scan_ratio,

   /* COMMON QUERY PROBLEMS IDENTIFIED BY QUERY PROFILE */

       /* 1) EXPLODING JOIN */
       CASE WHEN row_multiple > 1 THEN 1 ELSE 0 END AS EXPLODING_JOIN,

       /* 2) "UNION WITHOUT ALL" */
       CASE WHEN OPERATOR_TYPE = 'UnionAll' and lag(OPERATOR_TYPE) over (ORDER BY OPERATOR_ID) = 'Aggregate' THEN 1 ELSE 0 END AS UNION_WITHOUT_ALL,

       /* 3) Queries Too Large to Fit in Memory */
       CASE WHEN bytes_spilled_local>0 OR bytes_spilled_remote>0 THEN 1 ELSE 0 END AS QUERIES_TOO_LARGE_MEMORY,
      
       /* 4) Inefficient Pruning (numbers can be changed to fit your use case) */
       CASE WHEN partition_scan_ratio >= .8 AND partitions_total >= 20000 THEN 1 ELSE 0 END AS INEFFICIENT_PRUNING_FLAG

from table(get_query_operator_stats('your_query_id'))
ORDER BY STEP_ID,OPERATOR_ID
)
SELECT
   QUERY_ID,
   SYSTEM\$ESTIMATE_QUERY_ACCELERATION('your_query_id'),
   STEP_ID,
   OPERATOR_ID,
   PARENT_OPERATOR_ID,
   OPERATOR_TYPE,
   OPERATOR_STATISTICS,
   EXECUTION_TIME_BREAKDOWN,
   OPERATOR_ATTRIBUTES,
   OPERATOR_EXECUTION_TIME,
   OUTPUT_ROWS,
   INPUT_ROWS,
   ROW_MULTIPLE,
   BYTES_SPILLED_LOCAL,
   BYTES_SPILLED_REMOTE,
   PERCENTAGE_SCANNED_FROM_CACHE,
   TABLENAME,
   PARTITIONS_SCANNED,
   PARTITIONS_TOTAL,
   PARTITION_SCAN_RATIO,
   EXPLODING_JOIN,
   UNION_WITHOUT_ALL,
   QUERIES_TOO_LARGE_MEMORY,
   INEFFICIENT_PRUNING_FLAG
FROM query_stats;
--
--
EOF2
#
#
snowsql ${CONNECT_STRING}  > ${LOG_FILE}   2>&1
#
echo "                Query Operator Stats Report"  > ${REPORT_FILE}
echo "                ==========================="  >> ${REPORT_FILE}
#
cat ${LOG_FILE} >> ${REPORT_FILE}

clear
echo -n "View the report;press any key to continue..."
read DUMMY
view ${REPORT_FILE}
#
EOF1
#
}
#
# generate the script
# 
create_outer_wrapper_script
#
#execute the scrupt
#
execute_dynamically_generated_script
#
}
#
#
#
#########################################################################################
# Name     : show_clustering_primer
# Overview : The function shows the clustering primer.
#
# Notes    : 1. To convert to upper case :
#                   's,es/.*/\U&/
#            2.  To convert to loser case :
#                   's,es/.*/\L&/
#########################################################################################
show_clustering_primer()
{
cat <<EOF  >  ${TEMP_FILE_1}

                                Clustering Primer
                                =================

Q.Whai is clusetring ?
=====================
1. Clustering is similar to indexing.

Q. What is a Clustering Key?
============================
1. A clustering key is a subset of columns in a table (or expressions on a table) that are explicitly designated to co-locate the data in the table
   in the same micro-partitions.

Q. What is natural clustering ?
===============================
1. Natural clustering is when snowflake clusters the data of a table without any clustering key specified.

Q. How is natural clustering done ?
==================================

Table                          Micro Partitions
                               col  low_Val       high_val 
                               c1    2            10
                               c2    AB           ZZ 
                               c3    01-01-2000   05-01-2000
 
R1 (c1,c2,c3)                  MP-1->R1.c1, R2.c1, R3.c1
R2 (c1,c2,c3)                  MP-1->R1.c2, R2.c2, R3.c2
R3 (c1,c2,c3)                  MP-1->R1.c3, R2.c3, R3.c3

R4 (c1,c2,c3)                  MP-2->R1.c1, R2.c1, R3.c1
R5 (c1,c2,c3)                  MP-2->R1.c2, R2.c2, R3.c2
R6 (c1,c2,c3)                  MP-2->R1.c3, R2.c3, R3.c3

Notes
1. Snowflake will sort the data on column that it will see fit.

2. This is useful for very large tables where the ordering was not ideal (at the time the data was inserted/loaded) or extensive DML has caused the
   table’s natural clustering to degrade.

3. Some general indicators that can help determine whether to define a clustering key for a table include:

     - In general, Snowflake produces well-clustered data in tables; however, over time, particularly as DML occurs on very large tables
          (as defined by the amount of data in the table, not the number of rows), the data in some table rows might no longer cluster optimally on desired dimensions.

     - To improve the clustering of the underlying table micro-partitions, you can always manually sort rows on key table columns and re-insert them into the table;
        however, performing these tasks could be cumbersome and expensive.

     - Instead, Snowflake supports automating these tasks by designating one or more table columns/expressions as a clustering key for the table.
        A table with a clustering key defined is considered to be clustered.

     - You can cluster materialized views, as well as tables.
       The rules for clustering tables and materialized views are generally the same. 

q> when is clustering optimal ?
===============================
1. Clustering keys are not intended for all tables due to the costs of initially clustering the data and maintaining the clustering.
   Clustering is optimal when either:

          You require the fastest possible response times, regardless of cost.
          Your improved query performance offsets the credits required to cluster and maintain the table.


In this topic:

What is a Clustering Key?
A clustering key is a subset of columns in a table (or expressions on a table) that are explicitly designated to co-locate the data in the table in the same micro-partitions. This is useful for very large tables where the ordering was not ideal (at the time the data was inserted/loaded) or extensive DML has caused the table’s natural clustering to degrade.

Some general indicators that can help determine whether to define a clustering key for a table include:

Queries on the table are running slower than expected or have noticeably degraded over time.

The clustering depth for the table is large.

A clustering key can be defined at table creation (using the CREATE TABLE command) or afterward (using the ALTER TABLE command). The clustering key for a table can also be altered or dropped at any time.

Attention

Clustering keys cannot be defined for hybrid tables. In hybrid tables, data is always ordered by primary key.

Benefits of Defining Clustering Keys (for Very Large Tables)
Using a clustering key to co-locate similar rows in the same micro-partitions enables several benefits for very large tables, including:

Improved scan efficiency in queries by skipping data that does not match filtering predicates.

Better column compression than in tables with no clustering. This is especially true when other columns are strongly correlated with the columns that comprise the clustering key.

After a key has been defined on a table, no additional administration is required, unless you chose to drop or modify the key. All future maintenance on the rows in the table (to ensure optimal clustering) is performed automatically by Snowflake.

Although clustering can substantially improve the performance and reduce the cost of some queries, the compute resources used to perform clustering consume credits. As such, you should cluster only when queries will benefit substantially from the clustering.

Typically, queries benefit from clustering when the queries filter or sort on the clustering key for the table. Sorting is commonly done for ORDER BY operations, for GROUP BY operations, and for some joins. For example, the following join would likely cause Snowflake to perform a sort operation:

SELECT ...
    FROM my_table INNER JOIN my_materialized_view
        ON my_materialized_view.col1 = my_table.col1
    ...
In this pseudo-example, Snowflake is likely to sort the values in either my_materialized_view.col1 or my_table.col1. For example, if the values in my_table.col1 are sorted, then as the materialized view is being scanned, Snowflake can quickly find the corresponding row in my_table.

The more frequently a table is queried, the more benefit clustering provides. However, the more frequently a table changes, the more expensive it will be to keep it clustered. Therefore, clustering is generally most cost-effective for tables that are queried frequently and do not change frequently.

Note

After you define a clustering key for a table, the rows are not necessarily updated immediately. Snowflake only performs automated maintenance if the table will benefit from the operation. For more details, see Reclustering (in this topic) and Automatic Clustering.

CONSIDERATIONS FOR CHOOSING CLUSTERING FOR A TABLE
==================================================
Q. What are the considerations for choosing clustering for a table ?
====================================================================

1. Clustering is best for a table that meets all of the following criteria:

     1. The table contains a large number of micro-partitions.
        Typically, this means that the table contains multiple terabytes (TB) of data.

    2. The queries can take advantage of clustering. 
       Typically, this means that one or both of the following are true:
             - The queries are selective.
               In other words, the queries need to read only a small percentage of rows (and thus usually a small percentage of micro-partitions) in the table.

    3. The queries sort the data. (For example, the query contains an ORDER BY clause on the table.)

    4. A high percentage of the queries can benefit from the same clustering key(s).
      In other words, many/most queries select on, or sort on, the same few column(s).

2. If your goal is primarily to reduce overall costs, then each clustered table should have a high ratio of queries to DML operations (INSERT/UPDATE/DELETE).
   This typically means that the table is queried frequently and updated infrequently. 
   If you want to cluster a table that experiences a lot of DML, then consider grouping DML statements in large, infrequent batches.

3. Also, before choosing to cluster a table, Snowflake strongly recommends that you test a representative set of queries on the table to establish
   some performance baselines.

STRATEGIES FOR SELECTING CLUSTERING KEYS
========================================
Q. What are the strategies for selecting clustering keys ?
==========================================================

1. A single clustering key can contain one or more columns or expressions.

2. For most tables, Snowflake recommends a maximum of 3 or 4 columns (or expressions) per key.

3. Adding more than 3-4 columns tends to increase costs more than benefits.

4. Selecting the right columns/expressions for a clustering key can dramatically impact query performance.

5. Analysis of your workload will usually yield good clustering key candidates.

6. Snowflake recommends prioritizing keys in the order below:

        1. Cluster columns that are most actively used in selective filters
        2. For many fact tables involved in date-based queries (for example “WHERE invoice_date > x AND invoice date <= y”), choosing the date column is a good idea. 
           For event tables, event type might be a good choice, if there are a large number of different event types.
          (If your table has only a small number of different event types, then see the comments on cardinality below before choosing an event column as a clustering key.)

7. If there is room for additional cluster keys, then consider columns frequently used in join predicates, for example “FROM table1 JOIN table2 ON table7.7.   
   2.column_A = table1.column_B”.

8. If you typically filter queries by two dimensions (e.g. application_id and user_status columns), then clustering on both columns can improve performance.

9. The number of distinct values (i.e. cardinality) in a column/expression is a critical aspect of selecting it as a clustering key.
   It is important to choose a clustering key that has:
               - A large enough number of distinct values to enable effective pruning on the table.

               - A small enough number of distinct values to allow Snowflake to effectively group rows in the same micro-partitions.

               - A column with very low cardinality might yield only minimal pruning, such as a column named IS_NEW_CUSTOMER that contains only Boolean values. 
                 At the other extreme, a column with very high cardinality is also typically not a good candidate to use as a clustering key directly. 
                 For example, a column that contains nanosecond timestamp values would not make a good clustering key.

10. In general, if a column (or expression) has higher cardinality, then maintaining clustering on that column is more expensive.

11. The cost of clustering on a unique key might be more than the benefit of clustering on that key, especially if point lookups are not the primary use case 
    for that table.

12. If you want to use a column with very high cardinality as a clustering key, Snowflake recommends defining the key as an expression on the column, 
    rather than on the column directly, to reduce the number of distinct values.
    The expression should preserve the original ordering of the column so that the minimum and maximum values in each partition still enable pruning.

13. For example, if a fact table has a TIMESTAMP column c_timestamp containing many discrete values (many more than the number of micro-partitions in the table),
    then a clustering key could be defined on the column by casting the values to dates instead of timestamps (e.g. to_date(c_timestamp)). 
    This would reduce the cardinality to the total number of days, which typically produces much better pruning results.

14. As another example, you can truncate a number to fewer significant digits by using the TRUNC functions and a negative value for the scale
    (e.g. TRUNC(123456789, -5)).

Tip

If you are defining a multi-column clustering key for a table, the order in which the columns are specified in the CLUSTER BY clause is important. As a general rule, Snowflake recommends ordering the columns from lowest cardinality to highest cardinality. Putting a higher cardinality column before a lower cardinality column will generally reduce the effectiveness of clustering on the latter column.

Tip

When clustering on a text field, the cluster key metadata tracks only the first several bytes (typically 5 or 6 bytes). Note that for multi-byte character sets, this can be fewer than 5 characters.

In some cases, clustering on columns used in GROUP BY or ORDER BY clauses can be helpful. However, clustering on these columns is usually less helpful than clustering on columns that are heavily used in filter or JOIN operations. If you have some columns that are heavily used in filter/join operations and different columns that are used in ORDER BY or GROUP BY operations, then favor the columns used in the filter and join operations.

Reclustering
As DML operations (INSERT, UPDATE, DELETE, MERGE, COPY) are performed on a clustered table, the data in the table might become less clustered. Periodic/regular reclustering of the table is required to maintain optimal clustering.

During reclustering, Snowflake uses the clustering key for a clustered table to reorganize the column data, so that related records are relocated to the same micro-partition. This DML operation deletes the affected records and re-inserts them, grouped according to the clustering key.

Note

Reclustering in Snowflake is automatic; no maintenance is needed. For more details, see Automatic Clustering.

However, for certain accounts, manual reclustering has been deprecated, but is still allowed. For more details see Manual Reclustering.

Credit and Storage Impact of Reclustering
Similar to all DML operations in Snowflake, reclustering consumes credits. The number of credits consumed depends on the size of the table and the amount of data that needs to be reclustered.

Reclustering also results in storage costs. Each time data is reclustered, the rows are physically grouped based on the clustering key for the table, which results in Snowflake generating new micro-partitions for the table. Adding even a small number of rows to a table can cause all micro-partitions that contain those values to be recreated.

This process can create significant data turnover because the original micro-partitions are marked as deleted, but retained in the system to enable Time Travel and Fail-safe. The original micro-partitions are purged only after both the Time Travel retention period and the subsequent Fail-safe period have passed (i.e. minimum of 8 days and up to 97 days for extended Time Travel, if you are using Snowflake Enterprise Edition (or higher)). This typically results in increased storage costs. For more information, see Snowflake Time Travel & Fail-safe.

Important

Before defining a clustering key for a table, you should consider the associated credit and storage costs.

Reclustering Example
Building on the clustering diagram from the previous topic, this diagram illustrates how reclustering a table can help reduce scanning of micro-partitions to improve query performance:

Logical table structures after reclustering
To start, table t1 is naturally clustered by date across micro-partitions 1-4.

The query (in the diagram) requires scanning micro-partitions 1, 2, and 3.

date and type are defined as the clustering key. When the table is reclustered, new micro-partitions (5-8) are created.

After reclustering, the same query only scans micro-partition 5.

In addition, after reclustering:

Micro-partition 5 has reached a constant state (i.e. it cannot be improved by reclustering) and is therefore excluded when computing depth and overlap for future maintenance. In a well-clustered large table, most micro-partitions will fall into this category.

The original micro-partitions (1-4) are marked as deleted, but are not purged from the system; they are retained for Time Travel and Fail-safe.

Note

This example illustrates the impact of reclustering on an extremely small scale. Extrapolated to a very large table (i.e. consisting of millions of micro-partitions or more), reclustering can have a significant impact on scanning and, therefore, query performance.

DEFINING CLUSTERED TABLES
=========================

Calculating the Clustering Information for a Table
===================================================

Use the system function, SYSTEM$CLUSTERING_INFORMATION, to calculate clustering details, including clustering depth, for a given table. This function can be run on any columns on any table, regardless of whether the table has an explicit clustering key:

If a table has an explicit clustering key, the function doesn’t require any input arguments other than the name of the table.

If a table doesn’t have an explicit clustering key (or a table has a clustering key, but you want to calculate the ratio on other columns in the table), the function takes the desired column(s) as an additional input argument.

Defining a Clustering Key for a Table
=====================================
A clustering key can be defined when a table is created by appending a CLUSTER BY clause to CREATE TABLE:

CREATE TABLE <name> ... CLUSTER BY ( <expr1> [ , <expr2> ... ] )
Where each clustering key consists of one or more table columns/expressions, which can be of any data type, except GEOGRAPHY, VARIANT, OBJECT, or ARRAY. A clustering key can contain any of the following:

Base columns.

Expressions on base columns.

Expressions on paths in VARIANT columns.

For example:

EXAMPLE
=======

CLUSTER BY BASE COLUMNS
=======================

CREATE OR REPLACE TABLE t1 (c1 DATE, c2 STRING, c3 NUMBER) CLUSTER BY (c1, c2);

SHOW TABLES LIKE 't1';

+-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by     | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 12:06:07.517 -0700 | T1   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(C1, C2) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------+

CLUSTER BY EXPRESSIONS
======================

CREATE OR REPLACE TABLE t2 (c1 timestamp, c2 STRING, c3 NUMBER) CLUSTER BY (TO_DATE(C1), substring(c2, 0, 10));

SHOW TABLES LIKE 't2';

+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by                                     | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 12:07:51.307 -0700 | T2   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(CAST(C1 AS DATE), SUBSTRING(C2, 0, 10)) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------+

CLUSTER BY PATHS IN VARIANT COLUMNS
===================================

CREATE OR REPLACE TABLE T3 (t timestamp, v variant) cluster by (v:"Data":id::number);

SHOW TABLES LIKE 'T3';

+-------------------------------+------+---------------+-------------+-------+---------+-------------------------------------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by                                | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+-------------------------------------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 16:30:11.330 -0700 | T3   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(TO_NUMBER(GET_PATH(V, 'Data.id'))) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+-------------------------------------------+------+-------+----------+----------------+----------------------+
Important Usage Notes
For each VARCHAR column, the current implementation of clustering uses only the first 5 bytes.

If the first N characters are the same for every row, or do not provide sufficient cardinality, then consider clustering on a substring that starts after the characters that are identical, and that has optimal cardinality. (For more information about optimal cardinality, see Strategies for Selecting Clustering Keys.) For example:

create or replace table t3 (vc varchar) cluster by (SUBSTRING(vc, 5, 5));
If you define two or more columns/expressions as the clustering key for a table, the order has an impact on how the data is clustered in micro-partitions.

For more details, see Strategies for Selecting Clustering Keys (in this topic).

An existing clustering key is copied when a table is created using CREATE TABLE … CLONE. However, Automatic Clustering is suspended for the cloned table and must be resumed.

An existing clustering key is not supported when a table is created using CREATE TABLE … AS SELECT; however, you can define a clustering key after the table is created.

Defining a clustering key directly on top of VARIANT columns is not supported; however, you can specify a VARIANT column in a clustering key if you provide an expression consisting of the path and the target type.

CHANGING THE CLUSTERING KEY FOR A TABLE
=======================================

At any time, you can add a clustering key to an existing table or change the existing clustering key for a table using ALTER TABLE:

ALTER TABLE <name> CLUSTER BY ( <expr1> [ , <expr2> ... ] )
For example:

-- cluster by base columns
ALTER TABLE t1 CLUSTER BY (c1, c3);

SHOW TABLES LIKE 't1';

+-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by     | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 12:06:07.517 -0700 | T1   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(C1, C3) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+----------------+------+-------+----------+----------------+----------------------+

-- cluster by expressions
ALTER TABLE T2 CLUSTER BY (SUBSTRING(C2, 5, 15), TO_DATE(C1));

SHOW TABLES LIKE 't2';

+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by                                     | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 12:07:51.307 -0700 | T2   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(SUBSTRING(C2, 5, 15), CAST(C1 AS DATE)) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------+------+-------+----------+----------------+----------------------+

-- cluster by paths in variant columns
ALTER TABLE T3 CLUSTER BY (v:"Data":name::string, v:"Data":id::number);

SHOW TABLES LIKE 'T3';

+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------------------------------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by                                                                   | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------------------------------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 16:30:11.330 -0700 | T3   | TESTDB        | PUBLIC      | TABLE |         | LINEAR(TO_CHAR(GET_PATH(V, 'Data.name')), TO_NUMBER(GET_PATH(V, 'Data.id'))) |    0 |     0 | SYSADMIN | 1              | ON                   |
+-------------------------------+------+---------------+-------------+-------+---------+------------------------------------------------------------------------------+------+-------+----------+----------------+----------------------+
Important Usage Notes
When adding a clustering key to a table already populated with data, not all expressions are allowed to be specified in the key. You can check whether a specific function is supported using SHOW FUNCTIONS:

show functions like 'function_name';

The output includes a column, valid_for_clustering, at the end of the output. This column displays whether the function can be used in a clustering key for a populated table.

Changing the clustering key for a table does not affect existing records in the table until the table has been reclustered by Snowflake.

Dropping the Clustering Keys for a Table
At any time, you can drop the clustering key for a table using ALTER TABLE:

ALTER TABLE <name> DROP CLUSTERING KEY
For example:

ALTER TABLE t1 DROP CLUSTERING KEY;

SHOW TABLES LIKE 't1';

+-------------------------------+------+---------------+-------------+-------+---------+------------+------+-------+----------+----------------+----------------------+
| created_on                    | name | database_name | schema_name | kind  | comment | cluster_by | rows | bytes | owner    | retention_time | automatic_clustering |
|-------------------------------+------+---------------+-------------+-------+---------+------------+------+-------+----------+----------------+----------------------|
| 2019-06-20 12:06:07.517 -0700 | T1   | TESTDB        | PUBLIC      | TABLE |         |            |    0 |     0 | SYSADMIN | 1              | OFF                  |
+---------------------------


EOF
#
clear
echo -n "View time travel and failsafe primer;press any key to continue..."
read DUMMY
view ${TEMP_FILE_1}
#
}
#
#
#
#########################################################################################
# Name     : display_performance_optimisation_menu;;
# Overview : The function displaya performance optimisation menu.
#
#########################################################################################
display_performance_optimisation_menu()
{
MENU_NAME=pero

while true
do
clear

echo  -n "
######################################
# Performance Optimisation Menu      #
#                                    #
#   5. Show Primer                   #
#  10. Top 10  Queries               #
#  15. Top 10 Load                   # 
#  20. Top 10  Task                  # 
#  25. Poor Performance Query factors# 
#  30. Warehouse & Storage Tuning    # 
#  35. Performane Improving Steps    #
#  40. Explain PLan                  #
#  45. Get_Query_Operator_Stats      #
#  50. Clustering Primer             #
#  55. Perform Clustering            #
#                                    #
#  98. Root Menu                     # 
#  99. Exit                          # 
#                                    #
#                                    #
######################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 

done
#
#
}
#
#
########################################################################################
# Name     : display_root_menu
# Overview : The function displays root menu.
# Notes :
#########################################################################################
display_root_menu()
{
MENU_NAME=root
clear

echo  -n "
################################
#           Root Menu          #
#                              #
#   5. User Management         #
#  10. Role Management         #
#  15. Table Management        #
#  20. Data Loading/Unloading  #
#  25. Credit Monitoring       #
#  30. Cost Monitoring         #
#  35. Storage Monitoring      #
#  40. Cost Optimisation       #########
#  45. Virtual Warehouse Management    #
#  50. Dynamic Table Management#########
#  55. Task Management         #
#  60. Snowpipe  Management    #
#  65. Zero Copy Clone         #
#  70. SQL Optimisation        #
#  75. Event Management        #
#  75. Securitry Model         #
#  80. Data Sharing            #
#  85. Market Place            #
#                              #
#  99. Exit                    # 
#                              #
################################
"
echo  -n "    Enter Option-->"
read MENU_OPTION
process_menu_option 
}
#
#
########################################################################################
# Name     : process_menu_option
# Overview : The function processes menu option
# Notes :
#########################################################################################
process_menu_option()
{

if [  "${MENU_NAME}"  = "root"  ]
then
     case ${MENU_OPTION}   in
         5) display_user_management_menu ;;

        10) display_role_management_menu ;;

        15) display_table_management_menu ;;

        20) display_data_loading_menu ;;

        25) display_credit_monitor_menu ;;

        30) display_cost_monitor_menu;;

        35) display_data_storage_monitor_menu;;

        40) display_cost_optimisation_menu;;

        45) display_virtual_warehouse_management_menu;;

        50) display_dynamic_table_management_menu;;

        65) display_zero_copy_clone_menu;;

        70) display_performance_optimisation_menu;;

        99 ) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;
             display_root_menu ;;
     esac

elif [  "${MENU_NAME}"  = "usrm"  ]
then
     case ${MENU_OPTION}   in
         5) list_all_active_users;
            display_root_menu;;

        10) create_user ;;

        98 ) display_root_menu;;

        99 ) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "rolm"  ]
then
     case ${MENU_OPTION}   in
         5) list_all_roles;;

        10) list_all_grants_for_roles;;

        98 ) display_root_menu;;

        99 ) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "tabm"  ]
then
     case ${MENU_OPTION}   in
         5) time_travel_and_failsafe_primer;;

        10) list_all_tables;;

        15) list_tables_with_tt_and_fs_days;;

        20) create_table ;;

        25) show_table_design ;;

        98 ) display_root_menu;;

        99 ) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "dl"  ]
then
     case ${MENU_OPTION}   in
         5) list_all_stages;;

        10) list_files_in_all_user_stages;;

        15) list_files_in_current_user_stage;;

        20) load_unload_table_using_user_stage;;

        25) load_table_using_named_stage;;

        30) load_table_using_table_stage;;

        30) load_table_using_external_stage;;

        98 ) display_root_menu;;

        99 ) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "crem"  ]
then
     case ${MENU_OPTION}   in

        10) daily_credit_spend;;

        15) week_to_date_and_last_week_credit_spend;;

        20) month_to_date_and_last_month_credit_spend ;;

        98) display_root_menu;;

        99) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "cosm"  ]
then
     case ${MENU_OPTION}   in

        5 ) cost_primer;;

        ### 10) top_ten_table_storage;;
        #
        15) week_to_date_and_last_week_cost;;

        20) month_to_date_and_last_month_cost;;

        98) display_root_menu;;

        99) exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac


elif [  "${MENU_NAME}"  = "stom"  ]
then
     case ${MENU_OPTION}   in

         5) data_storage_metadata_views;;

        10) week_to_date_and_last_week_data_storage;;

        15) month_to_date_and_last_month_data_storage;;

        20) top_ten_storage_tables;;

        25) deleted_tables_with_storage;;

        98) display_root_menu;;

        99 )  exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "coop"  ]
then
     case ${MENU_OPTION}   in

        10.1) warehouse_credit_leakage_control;;

        15.1) table_credit_leakage_control ;;

        15.3) stage_credit_leakage_control ;;

        98) display_root_menu;;

        99 )  exit 0;;

         * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "vwam"  ]
then
     case ${MENU_OPTION}   in

        5) show_virtual_warehouse_primer ;;

       10) show_resource_monitor_primer ;;

       15) show_all_virtual_warehouses;;

       20) show_all_resource_monitors;;

       25) create_resource_monitor;;

       30) create_virtual_warehouse;;

       35) update_resource_monitor;;

       40) update_virtual_warehouse;;

       98) display_root_menu;;

       99)  exit 0;;

        *) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "dtam"  ]
then
     case ${MENU_OPTION}   in

        5) show_dynamic_table_primer;;

       10) create_dynamic_table ;;

       15) monitor_dynamic_table ;;

       20) query_dt_metadata ;;

       25) show_all_dynamic_tables;;

       30) drop_dynamic_table ;;

       98) display_root_menu;;

       99 )  exit 0;;

        * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "zccl"  ]
then
     case ${MENU_OPTION}   in

       5) show_zcc_primer;;

      10) list_all_cloned_tables ;;

      15) create_zcc_table ;;

      20) monitor_zcc_table;;

      25) query_zcc_metadata;;

      98) display_root_menu;;

      99) exit 0;;

       * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac

elif [  "${MENU_NAME}"  = "pero"  ]
then
     case ${MENU_OPTION}   in

       5) show_performance_optimisation_primer;;

      10) show_longest_running_query_details;;

      15) show_longest_running_load_details;;

      20) show_longest_running_task_details;;

      25) show_factors_contributing_to_poor_query_performance ;;

      30) warehouse_and_storage_tuning;;

      35) show_performance_improvement_steps;;

      40) explain_plan;;

      45) analyse_query_with_get_query_operator_stats ;;

      50) show_clustering_primer;;

      98) display_root_menu;;

      99) exit 0;;

       * ) echo -n "Invalid option entered;press any key to continue";
             read DUMMY;;
     esac
fi
#
#
}
#
#
########################################################################################################
# Name     : main
# Overview : The entry function.
# Notes    :
########################################################################################################
main()
{
initialise_variables 
display_root_menu
}
#
#
main
