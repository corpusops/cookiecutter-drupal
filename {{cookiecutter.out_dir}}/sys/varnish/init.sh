#!/bin/bash
SDEBUG=${SDEBUG-}

# now be in stop-on-error mode
set -e

# activate shell debug if SDEBUG is set
if [[ -n $SDEBUG ]];then set -x;fi

# export back the gateway ip as a host if ip is available in container
if ( ip -4 route list match 0/0 &>/dev/null );then
    ip -4 route list match 0/0 \
        | awk '{print $3" host.docker.internal"}' >> /etc/hosts
fi

# Varnish variables
export VARNISH_NO_CACHE_COOKIE=${VARNISH_NO_CACHE_COOKIE:-"NO_CACHE"}
export VARNISH_NO_CACHE_URL=${VARNISH_NO_CACHE_URL:-""}

VARNISH__HTTP_PROTECT_USER=${VARNISH__HTTP_PROTECT_USER:-""}
VARNISH__HTTP_PROTECT_PASSWORD=${VARNISH__HTTP_PROTECT_PASSWORD:-""}
if [ ! -z ${VARNISH__HTTP_PROTECT_USER} ]; then
    VARNISH_HTTP_AUTH=`printf "${VARNISH__HTTP_PROTECT_USER}:${VARNISH__HTTP_PROTECT_PASSWORD}"| base64`
fi
# start parameter
export VARNISH_MEMORY_SIZE=${VARNISH_MEMORY_SIZE:-"256MB"}

# vcl parameters
export ABSOLUTE_URL_DOMAIN=${ABSOLUTE_URL_DOMAIN}
export MONITORING_IP=${MONITORING_IP}
export LOAD_LANCER_IP=${LOAD_LANCER_IP}
export VARNISH_HTTP_AUTH=${VARNISH_HTTP_AUTH}
export VARNISH_HIDE_X_CACHE_TAGS=${VARNISH_HIDE_X_CACHE_TAGS}
export VARNISH_BACKENDS=${VARNISH_BACKENDS}
export VARNISH_PROBE_URL=${VARNISH_PROBE_URL}
export VARNISH_NO_CACHE_COOKIE=${VARNISH_NO_CACHE_COOKIE}
export VARNISH_NO_CACHE_URL=${VARNISH_NO_CACHE_URL}
export VARNISH_TTL_STATIC=${VARNISH_TTL_STATIC}
export VARNISH_TTL_STATIC_BROWSER=${VARNISH_TTL_STATIC_BROWSER}

log() {
    echo "$@" >&2;
}

vv() {
    log "$@";"$@";
}

#  configure: generate configs from template at runtime
configure() {
    # copy only if not existing template configs from common deploy project
    # and only if we have that common deploy project inside the image
    if [ ! -e etc ];then mkdir etc;fi
    for i in sys/etc local/*deploy-common/etc local/*deploy-common/sys/etc;do
        if [ -d $i ];then cp -rfnv $i/* etc >&2;fi
    done
    # install with frep any template file to / (eg: logrotate & cron file)
    for i in $(find etc -name "*.frep" -type f 2>/dev/null);do
        log $i
        d="$(dirname "$i")/$(basename "$i" .frep)" \
            && di="/$(dirname $d)" \
            && if [ ! -e "$di" ];then mkdir -pv "$di" >&2;fi \
            && echo "Generating with frep $i:/$d" >&2 \
            && frep "$i:/$d" --overwrite
    done
}

do_run() {
    varnishd \
      -F \
      -a http=:80,HTTP \
      -f /etc/varnish/varnish.vcl \
      -s malloc,$VARNISH_MEMORY_SIZE
}


# Configure VCL
configure

# Run app
do_run
