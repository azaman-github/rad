#######################################################################################
# Name     : erew.ksh(execute repl example wrapper)
# Overview : The script is used to allow users to run any repl examples from
#            following topics:
#                        - python
#                        - snowflake
#                        - aws
#                        - dbt
#                        - apache airflow
#                        - docker
#                        - dvt implementation in snowflake
#                        - terraform
#
# Notes    : 
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
export DOC=${REPL_HOME}/doc/q_and_a.txt
#
}
#
#
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
while true
do
  clear
  echo -n "View the master document;press any key to continue..."
  read DUMMY
  view ${DOC}
  if get_yn_acknowledgement  "Do you wish to quit(Y/N)?:"
  then
       break
  fi
done
}
#
#
main
