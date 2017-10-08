#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Info: Echoes dots every 4 seconds or number of seconds in arg1.

trap exit SIGPIPE

while sleep "${1:-4}" ; do
    if [ -n "${BASH_VERSION}" ] ; then
        echo -n '.' 1>&2
    elif [[ ${SHELL} = *[kz]sh ]] ; then
        echo '.\c' 1>&2
    else
        echo '.'
    fi
done
