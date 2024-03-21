#!/usr/bin/env bash
# Project Deployment script
QUESTION=0
VERSION=3.1
EXPLAIN="Manage project deployment"
WHOAMI=`basename $0`;
USAGE="--${WHOAMI} : v${VERSION} --
${EXPLAIN}

Usage: [ASK=yauto] ${WHOAMI}

"

. "$(dirname "${0}")/base.sh"

check_public_files_symlink

ask "$((QUESTION++))- Do you want to run a drush -y updb ?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    echo "${YELLOW}  - So we run drush -y updb${NORMAL}"
    call_drush -y updb
fi

ask "$((QUESTION++))- Rebuild all caches via drush?"
if [ "x${USER_CHOICE}" = "xok" ]; then
  call_drush -y cache:rebuild
fi
echo "${NORMAL}"

if [ "x${ASK}" == "xyauto" ]; then
    FORCE="-y "
else
    FORCE=""
fi
ask "$((QUESTION++))- Do you want to run a configuration import (drush cim)?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    if [ -e "$ROOTPATH/config/partial" ];then
        echo "${YELLOW}  - first we update the config_ignore configuration file (which prevents unwanted deletions)${NORMAL}"
        call_drush ${FORCE} config:import --partial --source='../config/partial'
        if [ "x${?}" = "x1" ]; then
            bad_exit "Failure in the 'config:import --partial --source='../config/partial', please check the previous lines for details."
        fi
    else
        echo "${YELLOW}  - first we run drush -y cim --partial sync (to let drush cim update the config_ignore exception list before removing the partial option -- which prevents deletions)${NORMAL}"
        call_drush ${FORCE} config:import --partial
        echo "${YELLOW}  - And we run run it a second time, because.. Drupal${NORMAL}"
        call_drush ${FORCE} config:import --partial

    fi
    echo "${YELLOW}  - And now we remove the --partial option, to perform deletions${NORMAL}"
    call_drush ${FORCE} config:import
    if [ "x${?}" = "x1" ]; then
        bad_exit "Failure in the 'drush cim --partial' step (upgrade configuration), please check the previous lines for details."
    fi
    echo "${YELLOW}  - And we run run it a second time, because.. Drupal${NORMAL}"
    call_drush ${FORCE} config:import
    if [ "x${?}" = "x1" ]; then
        bad_exit "Failure in the drush cim step (upgrade configuration), please check the previous lines for details."
    fi
fi

ask "$((QUESTION++))- Rebuild all caches via drush?"
if [ "x${USER_CHOICE}" = "xok" ]; then
  call_drush -y cache:rebuild
fi

ask "$((QUESTION++))- Launch deploy hooks via drush?"
if [ "x${USER_CHOICE}" = "xok" ]; then
  call_drush -y deploy:hook
fi

echo "${NORMAL}"

exit ${END_SUCCESS}
