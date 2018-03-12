#!/bin/sh

# abort if not run as root
if [[ `id -u` -gt 0 ]]; then
    echo "docker-entrypoint must be run as root" >&2
    exit 1
fi

# import scripts in entrypoint.d
for f in /usr/local/etc/entrypoint.d/*.sh; do
    if [[ -r $f ]]; then
        . $f
    fi
done

# allow the entrypoint to be overridden by environment variable
ENTRYPOINT="${entrypoint:-}"

# store the user to step down to if not starting supervisord
STEPDOWN_USER=$user

# unset bootstrapping variables the user may not care about
unset entrypoint user

# start supervisord if it's not running and there are no conflicting options
if [[ -z "$ENTRYPOINT" ]] \
    && [[ $# -eq 0 ]] \
    && [[ -z "$(grep supervisord /proc/1/cmdline)" ]] \
; then
    exec /usr/bin/supervisord -c /etc/supervisord.conf

    exit $?
fi

# detect the entrypoint if it's empty
if [[ -z "$ENTRYPOINT" ]] && [[ $# -eq 0 ]]; then
    # default to a bash login shell if no arguments specified
    ENTRYPOINT=/bin/bash
    set -- -l "$@"
elif [[ -z "$ENTRYPOINT" ]] && [[ "${1#-}" != "$1" ]]; then
    # command starts with a "-", e.g. -f or --version
    ENTRYPOINT=/usr/local/bin/php
elif [[ -z "$ENTRYPOINT" ]]; then
    # take the first argument to use as the entrypoint
    ENTRYPOINT=$1
    shift
fi

# try to resolve the full path of the entrypoint
if [[ ! -f "$ENTRYPOINT" ]]; then
    ENTRYPOINT=$(which "$ENTRYPOINT" || echo "$ENTRYPOINT")
fi

# step down to the non-root user and execute the entrypoint
exec su $STEPDOWN_USER -s "$ENTRYPOINT" -- "$@"
