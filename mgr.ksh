#####################################################################################################
#  Name    : mgr.ksh ( manage github repository)
#  Overview: The script is used to manage github repository
#  Notes   :
#
#  History :
#  Date              Author       Description
#  ================================================================================================
#  14/04/2025        A Zaman      Initial build.
###################################################################################################


###################################################################################################
#  Name    : initialise_variables
#  Overview: The function is used to initialise all global variables.
#  Notes   :
#=#################################################################################################
initialise_variables()
{
#
export REPO_HOME=""  # will be captured when prompted for repo path
export CURRENT_LOCAL_BRANCH=""
export CURRENT_REMOTE_BRANCH=""
#
export TEMP_DIR=/tmp
export TEMP_FILE_1=${TEMP_DIR}/mgr.tmp.1
export TEMP_FILE_2=${TEMP_DIR}/mgr.tmp.2
export TEMP_FILE_3=${TEMP_DIR}/mgr.tmp.3
#
export TRUE=0
export FALSE=1
#
}
#
#
#
#######################################################################################################
# Name     : get_yn_acknowledgement
# Overview : The function is used to get Y/N acknowledgement from user.
# Input    : string (message to be displayed)
# Notes    : 1. The message must be in following format :
#                "Do you wish to continue(Y/N):"
#######################################################################################################
get_yn_acknowledgement ()
{
#
export TRUE=0
export FALSE=1
#
#
P_MSG="${1}"
#
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
#######################################################################################################
# Name     : format_underscores
# Overview : The function is used to construct a line of undersrores that matches the length
#            of the input text.
# Input    : line of text
# Notes    : 1. It populates the global variable, UNDERSCORES .
#######################################################################################################
format_underscores()
{
TEXT_STRING="${1}"
TEXT_STRING_LEN=`echo -n  ${TEXT_STRING} | wc -c`
#
LOOP=0
UNDERSCORES=""
#
while [  $LOOP -lt ${TEXT_STRING_LEN}  ]
do
   UNDERSCORES="${UNDERSCORES}="
   LOOP=`expr $LOOP + 1`
done
#
}
#
###################################################################################################
#  Name    : get_repo_path
#  Overview: The function is used to get the repository path from user
#  Notes   :
##################################################################################################
get_repo_path()
{
clear
while true
do
    echo  -n "Please enter repository path ( or q to quit):?"
    read REPO_PATH
    if  [ "${REPO_PATH}"  = "q" ]
    then
           return $FALSE
    fi
    #
    # validate path
    #
    if [ ! -d  ${REPO_PATH}  ]
    then
        echo -n "Error: Invalid path(${REPO_PATH})h;press any key to continue..."
        read DUMMY
        return $FALSE
    fi
    #
    #check for valid repository
    #
    cd ${REPO_PATH}
    git status > ${TEMP_FILE_1}  2>&1
    if grep -i "not a git repository" ${TEMP_FILE_1}  > /dev/null  2>&1
    then
         echo -n "${REPO_PATH} is not a valid git repository;press any key to continue"
         read DUMMY
         return $FALSE
    fi
    #
    REPO_HOME=${REPO_PATH}
    # get the current local branch
    CURRENT_LOCAL_BRANCH=`git branch -l   | grep "^*" | awk {'print $2'}`
    CURRENT_REMOTE_BRANCH=`git branch -r  | grep -v "HEAD"  | grep ${CURRENT_LOCAL_BRANCH} | sed s/.' '//`
    break
done
#
#
}
#
#
###################################################################################################
#  Name    : get_branch_name
#  Overview: The function is used to get a branch name from user
#  Notes   :
##################################################################################################
get_branch_name()
{
while true
clear
do
    echo  -n "Please branch name ( or q to quit):?"
    read BRANCH_NAME 
    if  [ "${BRANCH_NAME}"  = "q" ]
    then
           return $FALSE
    fi
    #
    # validate  branch name
    #
    git switch ${BRANCH_NAME} > /dev/null  2>&1
    if [  $?  -eq 0 ]
    then
         return $TRUE
    else
        echo -n "Error:${BRANCH_NAME}, is an invalid  branch name;press any key to continue..."
        read DUMMY
    fi
    #
done
#
}
#
#
###################################################################################################
#  Name    : get_staged_file_name
#  Overview: The function is used to get a staged file name
#  Input   : STAGE_FILE_CHECK, STAGE_FILE_NAME
#  Notes   :
##################################################################################################
get_staged_file_name()
{
#
INPUT_PARAM=${1}
#
# get a list of staged file
#
> ${TEMP_FILE_1}  
git diff --staged --name-only  > ${TEMP_FILE_1}  
NOF=`cat ${TEMP_FILE_1} |  wc -l`
if [  $NOF  -eq  0 ]
then
     echo -n "There are no staged files to unstage;press any key to continue"   
     read DYMMY
     return $FALSE
fi
#
# Staged file exists
#
if [ "${INPUT_PARAM}" = "STAGE_FILE_CHECK"  ]
then
     return $TRUE
fi
#
while true
do
    clear
    echo  -n "Enter file name(or q to quit):"
    read REPLY
    if  [ "${REPLY}"  = "q" ]
    then
         return $FALSE
    fi
    #
    # validate file name
    #
    if grep ${REPLY}  ${TEMP_FILE_1}  > /dev/null 2>&1
    then
         STAGED_FILE_NAME=${REPLY}
         return $TRUE
    else
         echo -n "${REPLY}, is an invalid staged file name;press any key to continue..."
         read DUMMY
    fi
    
done
#
}
#
#
###################################################################################################
#  Name    : get_file_name
#  Overview: The function is used to get a file name from user
#  Notes   : 1. The function populates FILE_NAME variable.
##################################################################################################
get_file_name()
{
#
while true
do
    clear
    echo  -n "Enter file name(or q to quit):"
    read REPLY
    if  [ "${REPLY}"  = "q" ]
    then
         return $FALSE
    fi
    #
    if [ !  -f ${REPLY}  ]
    then
        echo -n "${REPLY}, does not exist;press any key to continue"
       read DUMMY
    else
        FILE_NAME=${REPLY}
        return $TRUE
    fi
done
}
#
#
#
###################################################################################################
#  Name    : get_version_no
#  Overview: The function is used to get a version number form  user
#  Notes   : 1. The function populates VERSION_NO variable.
##################################################################################################
get_version_no()
{
#
while true
do
    clear
    echo  -n "Enter required version no(1 latest version -1, 2 latest version -2, 3  latest version-3 etc)(or q to quit):"
    read REPLY
    case   ${REPLY}  in
         "") echo -n "Must enter an integer value;press any key to continue";
             read DUMMY ;
             continue ;;

         *) : ;;
    esac
 
    VERSION_NO=${REPLY}
    # test for integer
    if  `expr  ${VERSION_NO} + 1 > /dev/null 2>&1` 
    then
        # test for positive integer
        if [ ${VERSION_NO}  -lt 0  ]
        then
             echo -n "A negative integer,(${VERSION_NO}) is not allowed;press any key to continue"
             read DUMMY
             continue
        else
               return $TRUE
        fi
    else
         echo -n "Must enter an integer value;press any key to continue"
         read DUMMY
    fi
done
}
#
#
#
###################################################################################################
#  Name    : is_staged_file
#  Overview: The function is used to check if the input file is a staged file.
#  Input    : File name
#  Returns  : $TRUE  if file is a staged file
#             $FALSE if file is not s staged file
#  Notes   : 
##################################################################################################
is_staged_file()
{
#
INPUT_FILE=${1}
> ${TEMP_FILE_1}  
git diff --staged --name-only  >> ${TEMP_FILE_1}  

if grep ${INPUT_FILE} ${TEMP_FILE_1}  > /dev/null 2>&1
then
     return $TRUE
else
    return $FALSE
fi
#
}
#
#
#
###################################################################################################
#  Name    : list_all_branches
#  Overview: The function is used to show all branches
#  Notes   :
##################################################################################################
list_all_branches()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
cd ${REPO_HOME}
clear
echo "       Repository Remote Branches"
echo "       ========================="
git branch -r

echo -e "\n"

echo "       Repository Local Branches"
echo "       ========================="
git branch -l

echo  "* <branch name> signifies current branch"

echo -n "Press any key to continue..."
read DUMMY
#
}
#
#
###################################################################################################
#  Name    : show_current_status
#  Overview: The function is used to show current status of repository
#  Notes   :
##################################################################################################
show_current_status()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
cd ${REPO_HOME}
clear
echo "       Repository Status" 
echo "       ================="
git status
echo -n "Press any key to continue..."
read DUMMY
#
}
#
#
#
#
###################################################################################################
#  Name    : show_tracked_and_untracked_files_for_current_branch
#  Overview: The function is used to show tracked and untracked files in current branch
#  Notes   :
##################################################################################################
show_tracked_and_untracked_files_for_current_branch()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
#
cd ${REPO_HOME}
# list all files for current branch
#du -a |  sed   "/.\/.git/d" | awk {'print $2'} | sed s/'.\/'//  | sed s/^\\.// > ${TEMP_FILE_1}
#
git ls-tree -r ${CURRENT_LOCAL_BRANCH}  --name-only  > ${TEMP_FILE_1}
# list all remote files for this branch
git ls-tree -r ${CURRENT_REMOTE_BRANCH}  --name-only  > ${TEMP_FILE_2}
#
#prepare likst of local branch files that are missing from remote branch
#
HEADER="List of Local Branch(${CURRENT_LOCAL_BRANCH}) Files Missing from Remote Branch(${CURRENT_REMOTE_BRANCH})" 
format_underscores "${HEADER}"
echo       "${HEADER}"       > ${TEMP_FILE_3}
echo       "${UNDERSCORES}"  >> ${TEMP_FILE_3}

cat ${TEMP_FILE_1} | while read FNAME
do
  if grep "${FNAME}"  ${TEMP_FILE_2}  > /dev/null 2>&1
  then
       : 
  else
       echo "${FNAME} is missing from remote branch"  >> ${TEMP_FILE_3}
  fi

done
#
#prepare list of remote branch files that are missing from local branch
#
echo  -e  "\n"  >> ${TEMP_FILE_3}
HEADER="List of Remote Branch(${CURRENT_REMOTE_BRANCH}) Files Missing from Local Branch(${CURRENT_LOCAL_BRANCH})" 
format_underscores "${HEADER}"
echo       "${HEADER}"       >> ${TEMP_FILE_3}
echo       "${UNDERSCORES}"  >> ${TEMP_FILE_3}

cat ${TEMP_FILE_2} | while read FNAME
do
  if grep "${FNAME}"  ${TEMP_FILE_1}  > /dev/null 2>&1
  then
       : 
  else
       echo "${FNAME} is missing from local branch"   >> ${TEMP_FILE_3}
  fi

done
#

echo -n "View report;Press any key to  continue..."
read DUMMY
view ${TEMP_FILE_3}
#
#
}
#
#
###################################################################################################
#  Name    : show_commit_history_for_specific_file
#  Overview: The function is used to show commit history for specific  file
#  Notes   :
##################################################################################################
show_commit_history_for_specific_file()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
#
# prepare list of files for current branch
# 
COMM1="git ls-tree -r ${CURRENT_LOCAL_BRANCH}  --name-only  > ${TEMP_FILE_1}"
echo -n "Executing command (${COMM1}) to prepare a list of files for current branch;press any key to continue..."
read DUMMY
git ls-tree -r ${CURRENT_LOCAL_BRANCH}  --name-only  > ${TEMP_FILE_1}
view  ${TEMP_FILE_1}

while true
do
    clear
    echo -n "Enter file name(or q to quit):"
    read FNAME
    if [ "${FNAME}"   = "q"  ]
    then
         return $FALSE
    fi
    if  grep ${FNAME}  ${TEMP_FILE_1} > /dev/null 2>&1
    then
          break
    else
         echo -n " File ${FNAME}, does not exist in local branch(${CURRENT_LOCAL_BRANCH});press any key to continue.."
         read DUMMY
    fi
done
#
# prepare the commit history
#
echo   "Commit History for file, ${FNAME}"    > ${TEMP_FILE_3} 
echo   "=================================="   >> ${TEMP_FILE_3} 
git log ${FNAME}  >> ${TEMP_FILE_3}
COMM2="git log ${FNAME}  >> ${TEMP_FILE_3}"
echo -n "Executing command (${COMM2}) to get the commit history for specific file;press any key to continue..."
read DUMMY
#
echo -n "View Report;press any key to continue..."
read DUMMY
view ${TEMP_FILE_3}
#
#
}
#
#
#
###################################################################################################
#  Name    : show_all_changes
#  Overview: The function is used to show any changes in current branch.
#  Notes   : 1. These are files that have been modified and added to stage
#               with git add <file> command.
##################################################################################################
show_all_changes()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# prepare report online
# 
#
echo "Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
echo "================================================================================"
git status 

echo "Press any key to continue..."
read DUMMY
#
}
#
#
#
###################################################################################################
#  Name    : show_all_staged_changes
#  Overview: The function is used to show all staged changes
#  Notes   : 1. These are files that have been modified and added to stage 
#                using git add <file name> command.
#               
##################################################################################################
show_all_staged_changes()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# prepare report online
# 
#
echo "Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
echo "================================================================================"
git diff --staged --name-only

echo "Press any key to continue..."
read DUMMY
#
}
#
#
#
###################################################################################################
#  Name    : unstage_specfic_change
#  Overview: The function is used to unstage specific change in current branch.
#  Notes   : 1. The function will unstage a specific staged file.
#            2. After a file has been unstaged, you can not commit the change in that file.
#            3. File remains changed in os level.
#            4. Need to use git restore <file> to discard change.
##################################################################################################
unstage_specific_change()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# get a staged file name
#
if ! get_staged_file_name "STAGE_FILE_NAME"
then
     return $FALSE
fi
#
#
# prepare report online
# 
#
echo "Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
echo "================================================================================"
git  restore --staged ${STAGED_FILE_NAME}

echo "Press any key to continue..."
read DUMMY
#
}
#
#
#
###################################################################################################
#  Name    : unstage_all_changes
#  Overview: The function is used to unstage all changes in current branch.
#  Notes   : 1. The function will unstage all staged files.
#            2. After a file has been unstaged, you can not commit the change in that file.
#            3. File remains changed in os level.
#            4. Need to use git restore <file> to discard change.
##################################################################################################
unstage_all_changes()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
if ! get_staged_file_name "STAGE_FILE_CHECK"
then
     return $FALSE
fi
#
# prepare report online
# 
#
echo "Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
echo "================================================================================"
git reset

echo "Press any key to continue..."
read DUMMY
#
}
#
#
#
#
###################################################################################################
#  Name    : restore_file_to_specific_version
#  Overview: The function is used to restore a file to its specific version.
#  Notes   :
##################################################################################################
restore_file_to_specific_version()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# FILE_NAME is returned
# 
if ! get_file_name 
then
     return $FALSE
fi
#
# Uses $FILE_NAME
# 
if is_staged_file ${FILE_NAME}
then
     if ! get_yn_acknowledgement "Is it ok to unstage and restore staged file,${FILE_NAME}(Y/N):"
     then
          return $FALSE
     fi
     # unstage staged file
     git  restore --staged ${FILE_NAME}
     # restore file
     git restore ${FILE_NAME}
fi
#
# 
if ! get_version_no
then
      return $FALSE
fi
#
#
clear
HEADER="Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
format_underscores "${HEADER}"
echo "       ${HEADER}"
echo "       ${UNDERSCORES}"
#
#
COMM="git restore --source ${CURRENT_REMOTE_BRANCH}~${VERSION_NO}  ${FILE_NAME}"
echo "Executing command, ${COMM}"
git restore --source ${CURRENT_REMOTE_BRANCH}~${VERSION_NO}  ${FILE_NAME}

echo "Press any key to continue..."
read DUMMY
view ${FILE_NAME}

#
}
#
#
#
#
###################################################################################################
#  Name    : restore_file_to_last_version
#  Overview: The function is used to restore a specific file to is last version.
#  Notes   :
##################################################################################################
restore_file_to_last_version()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# FILE_NAME is returned
# 
if ! get_file_name 
then
     return $FALSE
fi
#
# Uses $FILE_NAME
# 
if is_staged_file ${FILE_NAME}
then
     if ! get_yn_acknowledgement "Is it ok to unstage and restore staged file,${FILE_NAME}(Y/N):"
     then
          return $FALSE
     fi
     # unstage staged file
     git  restore --staged ${FILE_NAME}
     # restore file
     git restore ${FILE_NAME}
fi
#
# 
#
echo "Remote Branch-->${CURRENT_REMOTE_BRANCH}  Local Branch-->${CURRENT_LOCAL_BRANCH}"
echo "================================================================================"
git restore --source ${CURRENT_REMOTE_BRANCH}~1  ${FILE_NAME}

echo "Press any key to continue..."
read DUMMY
view ${FILE_NAME}

#
}
#
#
#
#
###################################################################################################
#  Name    : show_git_primer
#  Overview: The function is used to show git primer
#  Notes   :
##################################################################################################
show_git_primer()
{
#
cat <<EOF  > ${TEMP_FILE_1}

                      Git Primer
                      ==========
Repository Creation
===================
1. The following 3 commands will initialise a local repository

git config --global user.email "Arif.Zaman@hotmail.co.uk"
git config --global user.name "azaman"
mkdir repo
cd repo
git init

repo<-- top level directory
|
|-------.git 
|        |-------HEAD
|        |-------branches(D)
|        |-------config
|        |-------description
|        |-------hooks(D)
|        |-------info (D)
|        |-------objects(D) <-- staged files + committed file
|        |-------refs(D)
|        |
|
|
|
|
|-------(F) <-----------
|-------(D) working tree
|-------(F) contains files and directories
|-------(F) contains tracked and untracked files
|-------(F)
|-------(F) <-----------
|


Concepts
========

Staging
=======
1. A file is staged in a temporary location, prepared to be committed later
2. A file is staged using the following command:
   git add <file name>

File Status
===========
Unchanged
Modified
Staged
Committed

Configuration
==============
1. To retrieve configuration information, use the following command:
$git config -l

HEAD
====
1. This is shown with a commit id.
2. This means that the current copy of the file in working tree has this change.

Example (README.md)
==================
--------------------------------------
Version=1  Commit# 1XXX mesage = version1
--------------------------------------

--------------------------------------
Version=2  commi# 2YYY mesage = version2
--------------------------------------

--------------------------------------
Version=3  commit# 3ZZZ mesage = version3
--------------------------------------
git log README.md

1XXX   HEAD (commit#3) <--file in working tree has this latest change (commit#3)
2YYY        (commit#2)
3ZZZ        (commit#1)                          

.gitignore file
===============
1. This file does not exist as default.
2. The contents of this file are file names amd directory names
3. This file tells git that ignore the files and directories mentioned
   in this file.
4. The file needs to created, staged and committed.

Example
=======

master
======
1. Name of the default branch, in a newly created repository.

Merge
=====
1. This is a process that combines changes in one file in one branch with
   that of in another branch.


Local repo
===========
1. Git creates and maintains its own repository

Merge
=====



Remote Repo
===========
1. Git can be used to clone a remote repo.

2. Once cloned, git manages it like a local repo

3. Any changes made is committed to local copy of remote repo when
    git commit command is used.

4. You must use git push to send the local commit details to remote repository.

5. Git will keep remote and its local copy in sync.

6. If conflict arises at any time, git will point this out and
   try to resolve automatically. If automatic conflict resolution fails,
   it'll inform the user to resolve conflict manually.




Repository Structure
====================
1. A repository is comprised of a number of branch
2. Traditionally one of the branch is called Main.


Repository Work Flow
====================

create file ------>git status------>git add README.md----->git commit README.md -m "First commit" 
README.md          shows modified   file is staged           Changes to file is committed
using editor       file name
                            ------->git add -p README.md 
                                    Stage file interactively
  
                            ------->git commit -a -m "First commit"       
                                    This adds the file to staging
                                    area before committing
                               

Change existing ------>git status------>git add README.md----->git commit README.md -m "First commit"----> git log README.md--------->git status
file, README.md        shows modified   file is staged            Changes to file is committed             shows all changes      on branch <branch name>
using editor           file name                                                                           to README.md           "nothing to commit,working tree clean"
                                                                                                                                   message displayed
                ------>git checkout README.md            ----->git revert HEAD READE.md
                       discard changes                         will restore previous 
                                                               version. Editor will open
                                                               for additional commit message
                                                     
                                                         ----->git revert <commit id> READE.md
                                                               will restore version
                                                               prior to this commit
                                                               Editor will open for
                                                               additional commit message



---->git log README.md------------>git log -p README.md-------->git show <commit id>----------> git --stat
      shows commit history         shows commit history         changes related to              shows summary
      changed contents             changed contents shown       this commit id shown            of changes
      not shown
                            ------->git log -P 2 README.md
                                    show last two commits



---->git diff README.md --------> git add README.md------->git diff --staged README.md------>git reset HEAD README.md
     shows changes in             file is staged           shows changes in stage             restore staged file
     modified file                                         file                               to current version
     againts latest version
     in working tree

---->git rm README.md--------> git commit -m "file removed" -------> git mv README.md README.txt---------> git commit -m "renamed file"
     Removes File              removes file is                       renames file in repository            renamed file is 
     from repository           committed                             and file system                       committed
     and file system

Repository Manipulation
=======================
Create
-------->git clone <repo url> ------>git init
         clones a remote repo     creates a local
                                  repository

Query
----->git remote -v
     shows urls
     associated with
     repo

Update

Delete

Branch Manipulation
===================

Create
------>git branch <new branch name------>git checkout -b <new branch name>
         creates new branch                creates and switches to
         does not switch to                branch 
         new branch
   
Query
---->git branch------>git branch -l ------>git branch -r --------->git remote show origin------>git status--------------->git fetch
    shows all         shows all            shows all remote        gives info about             gives info about        bring outstanding
    local branches    loacl branches       branches                origin remote repo           current branch          commit info
                                                                                                it might inform         for read only
                                                                                                that local out of date

---->git log  origin/master ----------->git log master--------------->git log --graph --oneline
       shows commit history          shows commit history                 graphical representation
       present in remote master      present in local master              of commit data  per line
       repo                          repo                                                                         

---->git log  origin/main
       shows commit history
       present in remote main
       repo                                                                             



git log output (1)
---------------------------------------------------------------------------------------------------------------------------------------------------------
commit 5488c826996e101bfbfc0d870b15783744ea95df (HEAD -> main, origin/main, origin/HEAD, xx, list, branches) <-- shows the HEAD for local and remote repo
Author: azaman-github <58461644+azaman-github@users.noreply.github.com>                                          points to same commit
Date:   Sun May 19 22:58:20 2024 +0100

    Latest Change via frontend

commit 0fa016ac08694e0f226dac43b26ce7f796841168
Author: azaman-github <58461644+azaman-github@users.noreply.github.com>
Date:   Fri May 17 14:21:55 2024 +0100

    Update README.md
---------------------------------------------------------------------------------------------------------------------------------------------------------
git log output (2)

commit d088b8ddbd8959e1edbd7a8711236f52ae613769 (HEAD -> main) <--- pointing to latest commit in local master
Author: azaman <Arif.Zaman@hotmail.co.uk>
Date:   Fri Apr 18 08:22:10 2025 +0000

    local change

commit 5488c826996e101bfbfc0d870b15783744ea95df (origin/main, origin/HEAD, xx, list, branches)<---- pointing to latest commit to remote master
Author: azaman-github <58461644+azaman-github@users.noreply.github.com>                             remote master is out of sink.
Date:   Sun May 19 22:58:20 2024 +0100                                                              The  latest commit in local master needs to be   
                                                                                                    pushed into remote master.
    Latest Change via frontend
--------------------------------------------------------------------------------------------------------------------------------------------------------


Update
----->git <branch name> ---------->git pull --------------------> git merge <remote branch name>
      creates this branch       fetches outstaning           this will fetch outstanding commits
      in  remote repo and       commits from remote            
      creates the mapping       and try to merge these
                                into local branch.
                                The merge might fail because
                                there is a commit in local
                                branch that is not in remote
                                branch


----->git add <changed file name> --------> git commit -m <message> --------> git push ------------->
        stage the changed file              commit the changes in           Send local commit 
                                              local repo                    details to remote
                                 

Delete
---->git  -d branch------>git D branch------>
      deletes             deletes
      branch              branch forcefully
Notes
1. You can not delete current branch ( ie. checked out branch)
2. Need to switch to another branch in order to delete the previously checked out branch)



---->git branch----------->git branch <new branch name>------>git checkout <existing branch name>----->git checkout -b <new branch name>
    shows all               creates new branch                 switches to named                       creates and switches to
    branches                does not switch to                 branch                                  new branch
    * denotes               new branch
    current branch

---->git branch -l----------->git branch -r----->git checkout <existing branch name>----->git checkout -b <new branch name>
    shows all                  shows all                 switches to named                       creates and switches to
    local branches            remote branches                 branch                                  new branch

Mergeing Changes
================
------->merge <branch name>/<file name> -----------> merge abort ------------->get pull
         merges the following files:                 abort current       fetch files from remote
         file from <branch name>                     merge               merge these into local branch
         file from local branch 


git log --graph --oneline

Repository Status
=================
1. At any point in time, the current branch will have one of the following status:
            - up-to-date with corresponding remote branch
            - has some modified files
            - has a conflict



MERGING
=======

Scenarion -1
Automatic Merge
1. C5 and C6 both edited C4
2. C5 and C6 edited different parts of the file
3. Neither has seen each other edit
4. C6 being merged 
5. The following message is displayed:
    head of branch for C5 is one commit behind
    merge conflit
    auto merge is possible
6. C6 becaomes the latest edit

Time line for file f1.txt
^
|
|<-------------C6
|
| C5 ( editing c4) edited line 2
|                  
|             C6 ( editing c4) edit line1
|
|<------------C4
|
|
| C3
|
|  merged
|<----------- C2
|
| C1
|

main         dev



Scenarion -1
Merge Conflict
===============
1. C5 and C6 both edited C4
2. Neither has seen each other edit
3. C5 and C6 edited the same line in the file
4. C6 being merged 
5. The following message is displayed:
    head of branch for C5 is one commit behind
    merge conflit
    auto merge not possible
6. git will create the file with conflicted edits ask you to resolve it


Time line for file f1.txt
^
|
|<-------------C6
|
| C5 ( editing c4) edited line 1
|                  
|             C6 ( editing c4) edit line1
|
|<------------C4
|
|
| C3
|
|  merged
|<----------- C2
|
| C1
|





Scenarion-1( no conflict)
=========================
branch              branch
main                dev
f1.dat              f1.dat

commits             commits
CCC line3 changed  HHHH line4 changed
BBB line2 changed
AAA line1 changed

git branch  main
git merge dev/f1.dat

commits
HHHH line4 changed <-- new change
CCC line3 changed   
BBB line2 changed
AAA line1 changed

Scenarion-2(conflict)
=====================
branch              branch
main                dev
f1.dat              f1.dat

commits             commits
CCC line3 changed   
BBB line2 changed   HHHH line3 changed ( did not see the commit CCC)`    
AAA line1 changed

git branch  main
git merge dev/f1.dat

CCC line3 changed    HHHH line3 changed 

Conflict
=========
Git does not now how to merge these two commits because each of these commits
were not aware of other commit.

Possible Resolutions
====================
1. Keep both commits
2. Delete commit, CCC
3. Delete commit, HHH
4. Delete all the commits

Git gives you the choice.
1. You must manually correct the conflict file that will have both commits
2. You must and commit the manually edited file using the following command:
   git commit <filename>

Notes
1. Interactive commit is required so that you can see the git constructed message.



EOF
#
clear
echo -n "View primer;press any key to continue..."
read dummy
view ${TEMP_FILE_1}
#
#
}
#
#
#
###################################################################################################
#  Name    : show_branch_mapping
#  Overview: The function is used to show local and remote branch mapping
#  Notes   :
##################################################################################################
show_branch_mapping()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
# get remote branch
#
git branch -r > ${TEMP_FILE_1}
clear
echo -n "Edit file (remove leading spaces and add forward slash at the beginning}; press any key to continue"
read DUMMY
view  ${TEMP_FILE_1}
# get local branch
clear
echo -n "Edit file (remove leading spaces and remove astesrisk;press any key to continue"
read DUMMY
git branch -l > ${TEMP_FILE_2}
view  ${TEMP_FILE_2}
#
clear
echo "          Branch Mapping"
echo "          ==============="

cat ${TEMP_FILE_2} | while read  LBN
do
   BREAK=0
   cat ${TEMP_FILE_1}  | while read RBN
   do
        SRBN=`basename ${RBN}`
        if [  "${LBN}"  =  "${SRBN}"   ]
        then
             #echo "Local Branch-->${LBN}  Remote Branch-->${RBN}"
             echo ${LBN} ${RBN} | awk {'printf("Local Branch-->%-10s   Remote Branch-->%-10s\n",$1,$2)'}
             > ${TEMP_FILE_3}
             break
        else
             continue
        fi
   done
   if [ -f ${TEMP_FILE_3}  ]
   then
       rm ${TEMP_FILE_3}
   else
       echo ${LBN}  | awk {'printf("Local Branch-->%-10s   Remote Branch-->Not Mapped\n",$1)'}
   fi

done
#
echo -n "Press any key to continue..."
read DUMMY


}
#
#
###################################################################################################
#  Name    : show_current_branch
#  Overview: The function is used to show current branch
#  Notes   :
##################################################################################################
show_current_branch()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
#
cd ${REPO_HOME}
clear
echo "       Current Branch (denoted by *)" 
echo "       ============================="
git  branch 
echo -n "Press any key to continue..."
read DUMMY

}
#
#
###################################################################################################
#  Name    : switch_branch
#  Overview: The function is used to switch to a specific branch
#  Notes   :
##################################################################################################
switch_branch()
{
if [ "${REPO_HOME}" = "" ]
then
      if ! get_repo_path
      then
            return $FALSE
      fi
fi
#
if ! get_branch_name 
then
     return $FALSE
fi
#
#
#
cd ${REPO_HOME}
clear
echo "       Current New Branch (denoted by *)" 
echo "       ================================="
git  branch 
echo -n "Press any key to continue..."
read DUMMY

}
#
#
###################################################################################################
#  Name    : display_root_menu
#  Overview: The function is used to display root menu.
#  Notes   :
##################################################################################################
display_root_menu()
{
export MENU_NAME=root

while true
do

clear
echo  -n "
###############################################
#           Manage GitHub Repository          #
#                                             #
#    5. List All Branches                     #
#   10. Show Current Status                   #
#   15. Show Tracked/Untracked Files          #
#       in Current branch                     #
#   20. Show Commit History for Specifc File  #
#   25. Show All Changes                      #
#   30. Show All Staged Changes               #
#   35. Unstage Specfic Staged Change         #
#   40. Unstage All Staged Changes            #
#   45. Restore File to Specific Version      #
#   50. Stash Unpushed Commits                #
#   55. Re-instate Unpushed Commits           #
#   60. Push Unpushed Commits                 #
#                                             #
#   75. Git Primer                            #
#   80. Show Branch Mapping                   #
#   85. Show current Branch                   #
#   90. Switch Branch                         #
#   95. Switch Repository                     #
#   99. Exit                                  #
###############################################
          Enter Option-->"

read MENU_OPTION
process_menu_option
#
done
#
#
}
#
#
###################################################################################################
#  Name    : process_menu_option
#  Overview: The function is used to process all menu options.
#  Notes   :
##################################################################################################
process_menu_option()
{
if [  "${MENU_NAME}"  = "root"  ]
then
    case ${MENU_OPTION}  in
        5) list_all_branches;; 
       10) show_current_status;; 
       15) show_tracked_and_untracked_files_for_current_branch;;
       20) show_commit_history_for_specific_file;;
       25) show_all_changes;;
       30) show_all_staged_changes;;
       35) unstage_specific_change;;
       40) unstage_all_changes;;
       45) restore_file_to_specific_version ;;
       55) show_branch_mapping;;
       60) show_current_branch;;
       65) switch_branch;;
       70) switch_repository;;

       99)  exit;;
        *) echo -n "Invalid option entered;press any key to continue...";
           read DUMMY;
    esac
fi
}
#
#
#
###################################################################################################
#  Name    : main
#  Overview: The function is used to implement processing structure 
#  Notes   :
#=#################################################################################################
main()
{
initialise_variables
display_root_menu
#
}
#
#
# invoke main
#
main
