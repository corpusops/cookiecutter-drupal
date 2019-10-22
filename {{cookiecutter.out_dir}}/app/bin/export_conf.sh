#!/usr/bin/env bash
# Drush cexy wrapper
# drush cexy, or drush config-export-plus allows finer config yml export
# --destination : An arbitrary directory that should receive the exported files. An alternative to label argument.
# --ignore-list
QUESTION=0
VERSION=1.0
EXPLAIN="Manage project yml config exports"
WHOAMI=`basename $0`;
USAGE="--${WHOAMI} : v${VERSION} --
${EXPLAIN}

Usage: [ASK=yauto] ${WHOAMI}

@see also help of config-import. This wrapper will export your local conf in sync/ directory.
Move things in install directory if you do not want this conf to override settings in other envs
like production or staging.

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
IGNORE_LIST_FILE=${ROOTPATH}/drush/config-ignore.yml
ask "$((QUESTION++))- Do you want to run a drush config export ?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    echo "${YELLOW}  - So we run drush cexy --destination=${LIB_SYNC} --ignore-list=${IGNORE_LIST_FILE}${NORMAL}"
    if [ "x${ASK}" == "xyauto" ]; then
        FORCE="-y "
    else
        FORCE=""
    fi
    call_drush ${FORCE} cexy --destination=${LIB_SYNC} --ignore-list=${IGNORE_LIST_FILE}
fi

exit ${END_SUCCESS}
