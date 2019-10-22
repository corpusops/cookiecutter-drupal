#!/usr/bin/env bash
# Project Deployment script
QUESTION=0
VERSION=3.0
EXPLAIN="Manage project deployment"
WHOAMI=`basename $0`;
USAGE="--${WHOAMI} : v${VERSION} --
${EXPLAIN}

Usage: [ASK=yauto] ${WHOAMI}

"

. "$(dirname "${0}")/base.sh"

check_default_symlink

ask "$((QUESTION++))- Do you want to run a drush -y updb ?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    echo "${YELLOW}  - So we run drush -y updb${NORMAL}"
    call_drush -y updb
fi

# TODO: regilero check d8
# echo
# echo "${YELLOW}check if acl rebuild is needed...${NORMAL}"
# RES=`call_drush vget node_access_needs_rebuild`
# if [ "xnode_access_needs_rebuild: 1" == "x${RES}" ] || [ "xnode_access_needs_rebuild: true" == "x${RES}" ]; then
#     echo "${YELLOW}...yes${NORMAL}"
#     call_drush -y node-access-rebuild
#     call_drush vset node_access_needs_rebuild 0
# else
#     echo "${YELLOW}...no${NORMAL}"
# fi

SYSTEM_YML="${ROOTPATH}/lib/config/sync/system.site.yml"
if [ ! -f ${SYSTEM_YML} ]; then
    SYSTEM_YML="${ROOTPATH}/lib/config/install/system.site.yml"
fi
if [ -f ${SYSTEM_YML} ]; then
    SITE_UUID=$(cat ${SYSTEM_YML}|grep uuid|tail -c +7|head -c 36)
    ask "$((QUESTION++))- Do you want to force site UUID to ${SITE_UUID}?"
    if [ "xok" = "x${USER_CHOICE}" ]; then
        echo "${YELLOW}  - So we run  config-set -y system.site uuid \"${SITE_UUID}\"${NORMAL}"
        verbose_call_drush config-set -y system.site uuid "${SITE_UUID}"
    fi
fi

#ask "$((QUESTION++))- Do you want to run a drush -y cim ?"
#if [ "xok" = "x${USER_CHOICE}" ]; then
#    echo "${YELLOW}  - So we run drush -y cim${NORMAL}"
#    verbose_call_drush -y cim
#fi
ask "$((QUESTION++))- Do you want to run a sbin/import_conf.sh (drush cimy) ?"
if [ "xok" = "x${USER_CHOICE}" ]; then
    echo "${YELLOW}  - So we run ASK=${ASK} ${BINPATH}/import_conf.sh{NORMAL}"
    ASK=${ASK} ${BINPATH}/import_conf.sh
fi

ask "$((QUESTION++))- Clear all caches via drush ?"
if [ "x${USER_CHOICE}" = "xok" ]; then
   drush_cr
fi
echo "${NORMAL}"

exit ${END_SUCCESS}
