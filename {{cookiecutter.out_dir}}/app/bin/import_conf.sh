#!/usr/bin/env bash
##############################
# DEPRECATED                 #
##############################
# Drush cimy wrapper
# drush cimy, or drush config-import-plus allows finer config yml import
# --preview
# --source : config/sync directory (yml we want to sync)
# --delete-list: file listing the list of yml files we WANT to delete from config
# --install : conf/install directory (yml with init only values)
# --skip-modules : A list of modules to ignore during import (e.g. to avoid disabling dev-only modules that are not enabled in the imported configuration).
QUESTION=0
VERSION=1.0
EXPLAIN="Manage project yml config imports"
WHOAMI=`basename $0`;
USAGE="--${WHOAMI} : v${VERSION} --
${EXPLAIN}

Usage: [ASK=yauto] ${WHOAMI}

HOW IT WORKS: ----------------------------------------------

1- As with drush cim --partial, drush cimy first it creates a temporary folder
2- Move one-time install configuration into the folder first
     - so active configuration will takes precedence over initial state
3-  export all active configuration (drush cex) from local install in the temp folder, overriding
     files from step 2 if they were already installed
4- delete any configuration found in active configuration that is listed in the delete list
     (the missing step from drush cim --partial)
5- copy the nominated config-export (lib/config/sync) (tracked in source control) over the top,
    taking final precedence.
6- import the result

AS A DEV WHAT SHOULD I TAKE CARE OF? ------------------------
- using config-export.sh (drush cexy) you will get everything, by default, in the sync folder (the one
used in step 5). You need to MOVE some things in the lib/config/install folder if it's a new conf that
need to be set.
 - lib/
     \- config/
          \- sync/    <-- yml of OVERWRITES/config you WANT (exported here by config-export)
          \- install/ <-- yml of INITIAL stuff (MANUAL MOVE by devs, default values)
 - drush/
     \- config-delete.yml  <--- list of files which needs to be DELETED (for config-import)
     \- config-ignore.yml  <--- list of files which are NOT EXPORTED (for config-export)
"

if [[ ($1 == "--help") ||  ($1 == "-h") ]]; then
  echo "${USAGE}"
  exit 0
fi

. "$(dirname "${0}")/base.sh"

LIB_SYNC=${ROOTPATH}/lib/config/sync/
LIB_INSTALL_ONLY=${ROOTPATH}/lib/config/install/
DELETE_LIST_FILE=${ROOTPATH}/drush/config-delete.yml
ask "$((QUESTION++))- Do you want to run a drush config import ?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    echo "${YELLOW}  - Here is a preview first${NORMAL}"
    echo "${YELLOW}  - drush cimy --preview --source=${LIB_SYNC} --install=${LIB_INSTALL_ONLY} --delete-list=${DELETE_LIST_FILE} --skip-modules=${SKIP_MODULES_FILE}${NORMAL}"
    call_drush -y cimy --preview --source=${LIB_SYNC} --install=${LIB_INSTALL_ONLY} --delete-list=${DELETE_LIST_FILE}
    ask "$((QUESTION++))- So really do it ?"
    if [ "xok" = "x${USER_CHOICE}" ]; then
         echo "${YELLOW}  - same command without the preview${NORMAL}"
        call_drush -y cimy --source=${LIB_SYNC} --install=${LIB_INSTALL_ONLY} --delete-list=${DELETE_LIST_FILE}
    fi
fi

exit ${END_SUCCESS}
