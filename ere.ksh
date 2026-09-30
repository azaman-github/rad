#######################################################################################
# Name     : ere.ksh(execute repl example)
# Overview : The script is used to perform repl ( READ-EVAL-PRINT-LOOP )function 
#            to edit and execute script from q_and_a.txt file.
#
# Notes    : 1. This script does the followings:
#                 - extract the example from main document
#                 - examine the script type directivae in the example
#                 - call internal functions to executes examples for:
#                        - python script
#                        - Docker image
#                        - Pandas script
#                        - Numpy script
#                        - Data Vault Model
#
#            3. It calls following script to execute dbt examples: 
#                       - d_repl.ksh
#
########################################################################################
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
#######################################################################################
# Name     : initialise_variables
# Overview : The function is used to initialise all variables
# Notes    :
########################################################################################
initialise_variables()
{
export REPL_HOME="/home/ec2-user/repl"
export REPL_TEMP="${REPL_HOME}/temp"
export REPL_LOG="${REPL_HOME}/log"

export PYTHON_REPL_HOME=${REPL_HOME}/python
export DOCKER_REPL_HOME=${REPL_HOME}/docker
export AIRFLOW_REPL_HOME=${REPL_HOME}/airflow
export SHELL_SCRIPT_REPL_HOME=${REPL_HOME}/shellscript
export AWK_SCRIPT_REPL_HOME=${REPL_HOME}/awkscript
export SED_SCRIPT_REPL_HOME=${REPL_HOME}/sedscript
export SQL_SCRIPT_REPL_HOME=${REPL_HOME}/sqlscript

export PYTHON_REPL_TEMP=${PYTHON_REPL_HOME}/temp
export DOCKER_REPL_TEMP=${DOCKER_REPL_HOME}/temp
export AIRFLOW_REPL_TEMP=${AIRFLOW_REPL_HOME}/temp
export SHELL_SCRIPT_REPL_TEMP=${SHELL_SCRIPT_REPL_HOME}/temp
export AWK_SCRIPT_REPL_TEMP=${AWK_SCRIPT_REPL_HOME}/temp
export SED_SCRIPT_REPL_TEMP=${SED_SCRIPT_REPL_HOME}/temp
export SQL_SCRIPT_REPL_TEMP=${SQL_SCRIPT_REPL_HOME}/temp

export PYTHON_REPL_LOG=${PYTHON_REPL_HOME}/log
export DOCKER_REPL_LOG=${DOCKER_REPL_HOME}/log
export AIRFLOW_REPL_LOG=${AIRFLOW_REPL_HOME}/log
export SHELL_SCRIPT_REPL_LOG=${SHELL_SCRIPT_REPL_HOME}/log
export AWK_SCRIPT_REPL_LOG=${AWK_SCRIPT_REPL_HOME}/log
export SED_SCRIPT_REPL_LOG=${SED_SCRIPT_REPL_HOME}/log
export SQL_SCRIPT_REPL_LOG=${SQL_SCRIPT_REPL_HOME}/log



export REPL_LOG=${REPL_HOME}/log

export DOC=${REPL_HOME}/doc/q_and_a.txt

export SCRIPT_FILE=${REPL_TEMP}/script_$$.txt

PYTHON_SCRIPT=${PYTHON_REPL_TEMP}/python_script_$$.py
AIRFLOW_PYTHON_SCRIPT=${AIRFLOW_REPL_TEMP}/airflow_python_script_$$.py
AIRFLOW_SHELL_SCRIPT=${AIRFLOW_REPL_TEMP}/airflow_shell_script_$$.ksh
DOCKER_SHELL_SCRIPT=${DOCKER_REPL_TEMP}/docker_shell_script_$$.ksh
SHELL_SCRIPT=${SHELL_SCRIPT_REPL_TEMP}/shell_script_$$.ksh
AWK_SCRIPT=${AWK_SCRIPT_REPL_TEMP}/awk_script_$$.ksh
SED_SCRIPT=${SED_SCRIPT_REPL_TEMP}/sed_script_$$.ksh
GH_ACTION_WORKFLOW_SCRIPT=${REPL_TEMP}/gh_action_workflow_script_$$.ksh
export SQL_SCRIPT=${SQL_SCRIPT_REPL_TEMP}/sql_script_$$.ksh
export SQL_COMMAND_FILE=${SQL_SCRIPT_REPL_TEMP}/sql_$$.sql
export CONNECT_STRING_VARS_FILE=${SQL_SCRIPT_REPL_TEMP}/sql_connect_strings.sql

#DBT variables
export DBT_HOME="${HOME}/home/gh/tutorial/dbt"
#

LAST_SCRIPT_EXECUTED=""
#
export LOG_FILE=""
export TEMP_FILE_1=""
export TEMP_FILE_2=""
#
export AIRFLOW_EXP_HOME="/tmp/airflow"
export AIRFLOW_ACTUAL_HOME="/home/ec2-user/tutorial/airflow"
export AIRFLOW_HOME=${AIRFLOW_ACTUAL_HOME}
#
}
#
#
#
#######################################################################################
# Name     : get_marker
# Overview : The function is used to get an example marker from the user .
# Notes    : 1. The function retrieves selected example from the tutorial and
#               then allows user to select from the list.
#
#            2. The selected example in the document is identified using following two tags:
#               +Example_Start 
#                Example_End
#            
########################################################################################
get_example_excerpt()
{
clear
#
#
MARKER_START="+Example_Start"
MARKER_END="Example_End"

LOG_FILE=${REPL_LOG}/script_$$.log

cd ${REPL_TEMP} 
csplit ${DOC}  /${MARKER_START}/+2    /${MARKER_END}/  > ${LOG_FILE}  2>&1
#
#read DUMMY
#
#
if [ ! -f xx00  -a  ! -f xx01   ]
then
     echo -n "Failed to split the file, (${DOC}); see error in the file that would be displayed next"
     read DUMMY
     view ${LOG_FILE}
     rm -f xx*
     exit 1
fi
#
#view  xx00 xx01 xx02
cat xx01 > ${SCRIPT_FILE}
mv xx01 xx01.prev
rm -f xx*
#view  ${SCRIPT_FILE}
#
}
#
#
##################################################################################
# Name     : edit_and_run_docker_example_as_shell_script
# Overview : 1. The function  extracts all relevant sections (Docker file, command to
#               create image and run command ) from ${SCRIPT_FILE}.
#
#            2. It finally executes the image to run the application. 
# Notes:    1. The script file  has following sections:
#                         APPLICATION-START
#                         #app  <name>.txt
#                         APPLICATION-END
#
#                         DOCKER-FILE-START
#                         DOCKER-FILE-END
#
#                         BUILD-IMAGE-START
#                         BUILD-IMAGE-END
#
#                         RUN-CONTAINER-START
#                         RUN-CONTAINER-END
# 
##################################################################################
edit_and_run_docker_example_as_shell_script()
{
# Extract python app
#
#view ${SCRIPT_FILE}
#
export LOG_FILE="${DOCKER_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${DOCKER_REPL_TEMP}/ere_1_$$.tmp"
export TEMP_FILE_2="${DOCKER_REPL_TEMP}/ere_2_$$.tmp"

cd ${DOCKER_REPL_TEMP}

#get the app name
TEMP_APP_FILE=`grep "#app" ${SCRIPT_FILE} | awk {'print $2'}`
DOCKERFILE="Dockerfile"
APP_FILE=`echo ${TEMP_APP_FILE}   | sed s/.py/_app.py/`
IMAGE_FILE=`echo ${TEMP_APP_FILE} | sed s/.py/.image.ksh/`
RUN_FILE=`echo   ${TEMP_APP_FILE} | sed s/.py/.run.ksh/`

MARKER_START="APPLICATION-START"
MARKER_END="APPLICATION-END"

rm -f  xx*
csplit ${SCRIPT_FILE}  /${MARKER_START}/+2    /${MARKER_END}/  > ${LOG_FILE}  2>&1
cat xx01 > ${APP_FILE}

MARKER_START="DOCKERFILE-START"
MARKER_END="DOCKERFILE-END"
rm -f  xx*
csplit ${SCRIPT_FILE}  /${MARKER_START}/+2    /${MARKER_END}/  > ${LOG_FILE}  2>&1
cat xx01 > ${DOCKERFILE}

MARKER_START="BUILD-IMAGE-START"
MARKER_END="BUILD-IMAGE-END"
rm -f  xx*
csplit ${SCRIPT_FILE}  /${MARKER_START}/+2    /${MARKER_END}/  > ${LOG_FILE}  2>&1
cat xx01 > ${IMAGE_FILE}


MARKER_START="RUN-CONTAINER-START"
MARKER_END="RUN-CONTAINER-END"
rm -f  xx*
csplit ${SCRIPT_FILE}  /${MARKER_START}/+2    /${MARKER_END}/  > ${LOG_FILE}  2>&1
cat xx01 > ${RUN_FILE}

#
FILE_LIST="${APP_FILE} ${DOCKERFILE} ${IMAGE_FILE} ${RUN_FILE}"
#view files
clear
while true
do

    echo -n "View and edit, if required, all files;press any key to continue..."
    read DUMMY
    echo ""   # without this read() does not work
    
    for fname in ${FILE_LIST}
    do
        clear
        echo -n "View file(${fname});press any key to continue..."
        read DUMMY
        vi $fname
    done
    #
    # build the image
    #
    clear
    echo -n "Building the image;press any key to continue..."
    read DUMMY
    chmod  777  ${IMAGE_FILE}
    sudo bash ${IMAGE_FILE} >  ${LOG_FILE}  2>&1
    echo -n "View the log file;press any key to continue..."
    read DUMMY
    vi ${LOG_FILE}
    #
    clear
    echo -n "Run the dockerfile;press any key to continue..."
    read DUMMY
    chmod  777  ${RUN_FILE}  
    sudo bash $RUN_FILE  > ${LOG_FILE}  2>&1
    echo -n "View the log file;press any key to continue..."
    read DUMMY
    vi  ${LOG_FILE}
    clear

    if ! get_yn_acknowledgement "Do you wish to continnue to edit and execute the script(Y/N)?"
    then
        LAST_SCRIPT_EXECUTED="${DOCKER_REPL_TEMP}/last_docker_file_executed.txt"  
        cp ${SCRIPT_FILE}    ${LAST_SCRIPT_EXECUTED}  
        cp ${LAST_SCRIPT_EXECUTED}   /tmp/last_docker_file_executed.txt
        break
   fi

done
#
#
}
#
#
##################################################################################
# Name     : edit_and_run_airflow_example_as_shell_script
# Overview : 1. The function is used to edit and execute airfkow example
#               as a shell script
#
# Notes:
# 
##################################################################################
edit_and_run_airflow_example_as_shell_script()
{

export LOG_FILE="${AIRFLOW_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${AIRFLOW_REPL_TEMP}/ere_1_$$.tmp"
export TEMP_FILE_2="${AIRFLOW_REPL_TEMP}/ere_2_$$.tmp"
#
#export LOG_FILE="${AIRFLOW_REPL_LOG}/ere.log"
#export TEMP_FILE_1="${AIRFLOW_REPL_TEMP}/ere_1.tmp"
#export TEMP_FILE_2="${AIRFLOW_REPL_TEMP}/ere_2.tmp"

cd ${AIRFLOW_REPL_TEMP}

> ${LOG_FILE}  

cp ${SCRIPT_FILE} ${AIRFLOW_SHELL_SCRIPT}

while true
do
   clear
   echo -n "View/Edit the script;press any key to continue..."
   read DUMMY
   view ${AIRFLOW_SHELL_SCRIPT}

   clear
   echo -n "Executing the script;press any key to continue..."
   read DUMMY
   chmod +x ${AIRFLOW_SHELL_SCRIPT}
   #${AIRFLOW_SHELL_SCRIPT} | tee  -a  ${LOG_FILE}  2>&1
   ${AIRFLOW_SHELL_SCRIPT} 
   clear
   #echo -n "View script execution log file;press any key to continue..."
   #read DUMMY
   #view  ${LOG_FILE}

   if ! get_yn_acknowledgement "Do you wish to continue to edit and execute the script(Y/N)?"
   then
        LAST_SCRIPT_EXECUTED="${AIRFLOW_REPL_TEMP}/last_airflow_shell_script_executed.ksh"  
        cp ${AIRFLOW_SHELL_SCRIPT}  ${LAST_SCRIPT_EXECUTED}
        break
   fi
done
#
#
}
#
#
##################################################################################
# Name     : edit_and_run_airflow_example_as_python_script()
# #
# Overview : 1. The function is used to edit and execute airflow example
#               as a python script
# Notes:
##################################################################################
edit_and_run_airflow_example_as_python_script()
{
export LOG_FILE="${AIRFLOW_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${AIRFLOW_REPL_TEMP}/ere_1_$$.tmp"
export TEMP_FILE_2="${AIRFLOW_REPL_TEMP}/ere_2_$$.tmp"

cp ${SCRIPT_FILE} ${AIRFLOW_PYTHON_SCRIPT}

# check if airflow is running
export SEARCH_STRING="airflow standalone" 
#
#
if ! ps -eaf | grep "${SEARCH_STRING}" | grep -v "${SEARCH_STRING}"   > ${LOG_FILE} 2>&1
then
     echo -n "airflow is not running;press any key to continue..."
     read DUMMY
     if [ ! -d "${AIRFLOW_HOME}"  ]
     then
         echo -n "airflow home(${AIRFLOW_HOME}) does not exist;creating it;press any key to continue..."
         read DUMMY
         mkdir ${AIRFLOW_HOME} > ${LOG_FILE}  2>&1
         if [ $?  -ne  0  ]
         then
             echo -n "Failed to create the directory;see log file in next step;press any key to continue..."
             read DUMMY
             vi ${LOG_FILE}
             return $FALSE
         fi

         echo -n "Initialise the database;press any key to continue..."
         read DUMMY
         airflow db migrate  > ${LOG_FILE}  2>&1
         if [ $?  -ne  0  ]
         then
             echo -n "Failed to initialise the db;see log file in next step;press any key to continue..."
             read DUMMY
             vi ${LOG_FILE}
             return $FALSE
         fi
     fi
fi
#
#
sed  's/load_examples=.*/load_examples=False'/ ${AIRFLOW_CONFIG_FILE}  > ${TEMP_FILE}
cat  ${TEMP_FILE} > ${AIRFLOW_CONFIG_FILE}
clear
echo -n "starting airflow with airflow standalone command;press any key to continue..."
read DUMMY
airflow standalone > ${LOG_FILE}  2>&1
if [ $?  -ne 0 ]
then
       echo -n "Failed to start airflow;see log file in next atep;press any key to conatine..."
       read DUMMY
       return $FALSE
fi
#
##
while true
do
    clear
    echo -n  "View/Edit script file (${AIRFLOW_PYTHON_SCRIPT}); press any key to continue..."
    read DUMMY
    view  ${AIRFLOW_PYTHON_SCRIPT}
    #
    clear 
    echo -n "Do you wish to execute the program in interactive mode(Y/N)?:"
    read REPLY
    if [  "${REPLY}" = "Y"  -o  "${REPLY}" = "y"  ]  
    then
        clear
        echo -n "Executing the script in intercative mode;Press any key to continue..."
        read DUMMY
        python3  ${AIRFLOW_PYTHON_SCRIPT} 
    else
        clear
        echo -n "Executing the script in batch mode;Press any key to continue..."
        read DUMMY
        python3  ${AIRFLOW_PYTHON_SCRIPT}  > ${LOG_FILE}  2>&1 
        echo -n "View script execution log file;press any key to continue..."
        read DUMMY
        view  ${LOG_FILE}
    fi

    clear
    if ! get_yn_acknowledgement "Do you wish to continnue to edit and execute the script(Y/N)?"
    then
        LAST_SCRIPT_EXECUTED="${AIRFLOW_REPL_TEMP}/last_airflow_python_script_executed.py"  
        cp ${AIRFLOW_PYTHON_SCRIPT}    ${LAST_SCRIPT_EXECUTED}  
        cp ${AIRFLOW_PYTHON_SCRIPT}   /tmp/last_airflow_python_script_executed.py
        break
    fi
done

}
#
#
#######################################################################################
# Name     : edit_and_run_shell_script_example
# Overview : The function is used to view/edit/execute a shell script
# Notes    :
########################################################################################
edit_and_run_shell_script_example()
{
#
export LOG_FILE="${SHELL_SCRIPT_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${SHELL_SCRIPT_REPL_TEMP}/ere_1_$$.tmp"

cp ${SCRIPT_FILE} ${SHELL_SCRIPT}

while true
do
   clear
   echo -n  "View/Edit script file (${SHELL_SCRIPT}); press any key to continue..."
   read DUMMY
   view  ${SHELL_SCRIPT}
   #
   #
   clear
   echo -n "Do you wish to pass command line parameter values(Y/N)?:"
   read REPLY
   if [  "${REPLY}" = "Y"  -o  "${REPLY}" = "y"  ]  
   then
       clear
       echo -n  "Enter your parameter values:"
       read PVALUES
   fi
   clear
   echo -n "Executing the script in batch mode;Press any key to continue..."
   read DUMMY
   chmod +x ${SHELL_SCRIPT}  > ${LOG_FILE}  2>&1 
   #${SHELL_SCRIPT} ${PVALUES}   > ${LOG_FILE}  2>&1 
   ${SHELL_SCRIPT} ${PVALUES}   
   #echo -n "View script execution log file;press any key to continue..."
   #read DUMMY
   #view  ${LOG_FILE}
   #
   clear
   if ! get_yn_acknowledgement "Do you wish to continnue to edit and execute the script(Y/N)?"
   then
        LAST_SCRIPT_EXECUTED="${SHELL_SCRIPT_REPL_TEMP}/last_python_script_executed.py"  
        cp ${SHELL_SCRIPT}    ${LAST_SCRIPT_EXECUTED}  
        cp ${SHELL_SCRIPT}   /tmp/last_shell_script_executed.ksh
        break
   fi
done
#
}
#
#
#######################################################################################
# Name     : edit_and_run_awk_script_example
# Overview : The function is used to view/edit/execute an awk script
# Notes    :
########################################################################################
edit_and_run_awk_script_example()
{
#
export LOG_FILE="${AWK_SCRIPT_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${AWK_SCRIPT_REPL_TEMP}/ere_1_$$.tmp"

cp ${SCRIPT_FILE} ${AWK_SCRIPT}
#
}
#
#
#######################################################################################
# Name     : edit_and_run_sed_script_example
# Overview : The function is used to view/edit/execute a sed script
# Notes    :
########################################################################################
edit_and_run_sed_script_example()
{
#
export LOG_FILE="${SED_SCRIPT_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${SED_SCRIPT_REPL_TEMP}/ere_1_$$.tmp"
cp ${SCRIPT_FILE} ${SED_SCRIPT}
#
}
#
#
#######################################################################################
# Name     : view_edit_execute_sql_command_file
# Overview : The function is used to view, edit and execute sql command file
# Notes    :
########################################################################################
view_edit_execute_sql_command_file ()
{

clear
echo -n "View/Edit sql command file; press any key to continue..."
read DUMMY
view ${SQL_COMMAND_FILE}

clear
echo -n "Edit userid and password for the connection; press any key to continue..."
read DUMMY
view ${CONNECT_STRING_VARS_FILE}
.  ${CONNECT_STRING_VARS_FILE}
#
#
clear
echo -n "Executing sql coammnd file; press any key to continue..."
read DUMMY
#snowsql -a ${SNOWSQL_ACCOUNT}  -u ${SNOWSQL_USER} -m ${TOTP} \
#
snowsql -c dev_session  -f ${SQL_COMMAND_FILE} > ${LOG_FILE} 2>&1

clear
echo -n "View sql command file execution log; press any key to continue..."
read DUMMY
view ${LOG_FILE} 
#
#
}
#
#
#
#######################################################################################
# Name     : pre_populate_sql_command_file 
# Input    : Command file name
# Overview : The function is used to prepopulate sql command file
# Notes    :
########################################################################################
pre_populate_sql_command_file ()
{
#
cat   <<EOF  > ${SQL_COMMAND_FILE}
!set echo=True
!set timing=True
--
/*
use database scratch;
use schema  workspace;
use warehouse xsmall;
*/
--
-- use these details to !connect to a new session
--
/*
select
current_account(),
current_role(),
current_database(),
current_schema(),
current_date(), 
current_time(),
current_user() ;
*/
--
-- write your  sql here
--
EOF
#
#
#
}
#
#
#######################################################################################
# Name     : prepopulate_connect_string_vars_file 
# Overview : The function is used to prepopulate connect string variables script.
# Notes    :
########################################################################################
prepopulate_connect_string_vars_file ()
{
#
cat   <<EOF  > ${CONNECT_STRING_VARS_FILE}
#export SNOWSQL_USER=u1
#export SNOWSQL_USER=u2
#export SNOWSQL_USER=azaman
#
#export SNOWSQL_PWD=p1
#export SNOWSQL_PWD=p2
#export SNOWSQL_PWD="Nurmak01__"
#
#export TOTP="change this value"

#export SNOWSQL_PWD="Nurmak01__<change_this_value>"
#
EOF
#
chmod +x  ${CONNECT_STRING_VARS_FILE}
#
#
}
#
#
#
#######################################################################################
# Name     : aasemble_edit_and_run 
# Overview : The function is used to allow followings in a loop:
#               - editing of sql command file that may include shell code to create a os file.
#               - view output
# Notes    :
########################################################################################
aasemble_edit_and_run ()
{
#
pre_populate_sql_command_file
prepopulate_connect_string_vars_file 

# add extracted sql script
cat ${SCRIPT_FILE} >>  ${SQL_COMMAND_FILE}

while true
do
   view_edit_execute_sql_command_file

   if ! get_yn_acknowledgement "Do you wish to continnue to edit and run the sql command file(Y/N)?"
   then
     break
   else
     continue
   fi
done
#
}
#
#
#
#
#######################################################################################
# Name     : edit_and_run_sql_script_example()
# Overview : The function is used to view/edit/execute a sql script
# Notes    :
########################################################################################
edit_and_run_sql_script_example()
{
export LOG_FILE="${SQL_SCRIPT_REPL_LOG}/ere_$$.log"
export TEMP_FILE_1="${SQL_SCRIPT_REPL_TEMP}/ere_1_$$.tmp"

aasemble_edit_and_run 

}
#
#
#
#
#
#######################################################################################
# Name     : edit_and_run_python_example 
# Overview : The function is used to allow followings in a loop:
#               - editing of sql command file that may include shell code to create a os file.
#               - view output
# Notes    :
########################################################################################
edit_and_run_python_example ()
{
#
cp ${SCRIPT_FILE} ${PYTHON_SCRIPT}

while true
do
   clear
   echo -n  "View/Edit script file (${PYTHON_SCRIPT}); press any key to continue..."
   read DUMMY
   view  ${PYTHON_SCRIPT}
   #
   #
   if grep "#NEEDS-GUI" ${PYTHON_SCRIPT} > /dev/null  2>&1
   then
       cp  ${PYTHON_SCRIPT} /tmp/vp.py 
       echo -n "Run vp.bat in windows;come back and press any key to continue..."
       read DUMMY
       # view log
       #view /tmp/vp.log
       if ! get_yn_acknowledgement "Do you wish to continnue to edit and execute the script(Y/N)?"
       then
            break
       else
            continue
       fi
   fi


   echo -n "Do you wish to execute the program in interactive mode(Y/N)?:"
   read REPLY
   if [  "${REPLY}" = "Y"  -o  "${REPLY}" = "y"  ]  
   then
       clear
       echo -n "Executing the script in intercative mode;Press any key to continue..."
       read DUMMY
       python3  ${PYTHON_SCRIPT} 
     read DUMMY

   else
       #Look for COMMAND-LINE directive
       #ARGS=list of arguments
       ARGS=`grep "#ARGUMENTS" ${PYTHON_SCRIPT} | cut -d":" -f2`
       if [  "${ARGS}"  != "" ]
       then
           clear
           echo -n "Executing the script with arguments(${ARGS});Press any key to continue..."
           read DUMMY
           python3 ${PYTHON_SCRIPT}  ${ARGS}  > ${LOG_FILE}  2>&1 
       else
           echo -n "Executing the script in batch mode;Press any key to continue..."
           read DUMMY
           python3  ${PYTHON_SCRIPT}  > ${LOG_FILE}  2>&1 
       fi
       echo -n "View script execution log file;press any key to continue..."
       read DUMMY
       view  ${LOG_FILE}
   fi
   #
   clear
   if ! get_yn_acknowledgement "Do you wish to continnue to edit and execute the script(Y/N)?"
   then
        LAST_SCRIPT_EXECUTED="${PYTHON_REPL_TEMP}/last_shell_script_executed.ksh"  
        cp ${PYTHON_SCRIPT}    ${LAST_SCRIPT_EXECUTED}  
        cp ${PYTHON_SCRIPT}   /tmp/last_python_script_executed.py
        break
   fi
done
#
}
#
#
#######################################################################################
# Name     : edit_and_check_gh_action_script_example
# Overview : The function is used to edit and syntax check GitHub Action workflow script
# Notes    :
########################################################################################
edit_and_check_gh_action_script_example()
{

export TEMP_FILE_1="${REPL_TEMP}/ere_1_$$.tmp"

cp ${SCRIPT_FILE} ${GH_ACTION_WORKFLOW_SCRIPT}

while true
do
  clear
  echo  -n "View/Edit GitHub Action workflow script;press any key to continue..."
  read DUMMY
  view ${GH_ACTION_WORKFLOW_SCRIPT}
  #
  clear
  echo  -n "Running actionlint;press any key to continue..."
  read DUMMY
  actionlint ${GH_ACTION_WORKFLOW_SCRIPT}  > ${TEMP_FILE_1}  2>&1
  clear
  echo  -n "View actionlint results;press any key to continue..."
  read DUMMY
  view ${TEMP_FILE_1}

  if get_yn_acknowledgement "Do you wish to continnue to edit and check the script(Y/N)?"
  then
       continue
  else
       break 
  fi

done
#
}

#
#
#######################################################################################
# Name     : main
# Overview : Entry function for the script
# Notes    :
########################################################################################
main()
{

initialise_variables

get_example_excerpt

if  grep -i "#DOCKER"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_docker_example_as_shell_script
#
elif  grep -i "#AIRFLOW-SHELL"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_airflow_example_as_shell_script
#
elif  grep -i "#AIRFLOW-PYTHON"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_airflow_example_as_python_script
#
elif  grep -i "#SHELL-SCRIPT"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_shell_script_example

elif  grep -i "#AWK-SCRIPT"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_awk_script_example

elif  grep -i "#SED-SCRIPT"  ${SCRIPT_FILE}  > /dev/null  2>&1
then
        edit_and_run_awk_sed_script_example

elif  grep -i "^--SQL-SCRIPT"  ${SCRIPT_FILE}  
then 
        edit_and_run_sql_script_example

elif  grep -i "^#GH-ACTION-WORKFLOW-SCRIPT"  ${SCRIPT_FILE}  
then 
        edit_and_check_gh_action_script_example

elif  grep -i "^--DBT-SCRIPT"  ${SCRIPT_FILE}  
then 
    #extract Example name
    EXAMPLE_NAME=`grep -i "^EXAMPLE=" ${SCRIPT_FILE}  | cut -d "=" -f2`
    ${HOME}/bin/d_repl.ksh ${EXAMPLE_NAME} ${SCRIPT_FILE}
else
        edit_and_run_python_example
fi

}
#
#
main
