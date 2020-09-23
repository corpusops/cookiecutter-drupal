#!/usr/bin/env bash
. "$(dirname "${0}")/base.sh"

cd "${WWW_DIR}" || die "no $WWW_DIR"

# test mysql availability
if ! call_drush sqlq "SELECT 'TEST_DB_CONN'" 2>&1 | egrep -q "^\s*TEST_DB_CONN$";then
    die "DB server is not available, install skipped"
fi

# if installation was never done,
# we will certainly have less than 10 tables in datase
do_install=""
if ! has_ignited_db;then
    do_install="y"
fi

env
echo "testing ${DRUPAL_FORCE_INSTALL}"
if [ ! -z ${DRUPAL_FORCE_INSTALL} ]; then
    log "DRUPAL_FORCE_INSTALL variable is set: Db overwrite allowed"
    do_install="y"
fi

if [ "x${do_install}" = "x" ];then
    log "Install skipped, an installation already exists, set env DRUPAL_FORCE_INSTALL to overwrite that database"
    exit 0
fi

if [ -z $ADMIN_PASS ]; then
    die "ADMIN_PASS env variable is not SET, cannot install Drupal!"
fi

# Manually drop tables because drush site-install is an idiot
call_drush sql-drop -y

# First install (no exported conf), use the real profile
settings_folder_write_fix
chmod u+rw "${WWW_DIR}/sites/default/settings.php"
verbose_call_drush site-install -v -y \
    --account-mail="${ADMIN_MAIL}" \
    --account-name="${ADMIN_NAME}" \
    --account-pass="${ADMIN_PASS}" \
    --db-url="${DATABASE_DRIVER}://${DATABASE_USER}:${DATABASE_PASSWD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}" \
    --site-mail="${SITE_MAIL}" \
    --site-name="${SITE_NAME}" \
    --sites-subdir="${SITES_SUBDIR}" \
    --existing-config \
    --debug \
    "${PROFILE_NAME}" \
    install_configure_form.enable_update_status_emails=NULL \
    install_configure_form.site_default_country=${SITE_DEFAULT_COUNTRY} \
    install_configure_form.date_default_timezone=${DATE_DEFAULT_TIMEZONE} \
    install_configure_form.update_status_module=${UPDATE_STATUS_MODULE} \
    ${EXTRA_DRUSH_SITE_INSTALL_ARGS}
ret=$?
exit $ret
