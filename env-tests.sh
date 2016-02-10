# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Tests

# ##############################################################################
# File tests

_any_not_w () {

    for i in "$@" ; do
        [ -n "${1}" -a ! -w "${1}" ] && return 0
    done

    return 1
}

# ##############################################################################
# Value tests

_any_null () { 

    for i in "$@" ; do
        [ -z "${i}" ] && return 0
    done

    return 1
}

_all_not_null () { 

    for i in "$@" ; do
        [ -z "${i}" ] && return 1
    done

    return 0
}

