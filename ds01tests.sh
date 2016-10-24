# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Environment testing

_is_aix () { [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; }
_is_cygwin () { [[ "$(uname -a)" = *[Cc]ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] || _is_debian || _is_ubuntu ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }

# ##############################################################################
# Filesystem testing

_all_not_null () {
    for i in "$@" ; do
        [ -z "${i}" ] && return 1
    done
    return 0
}

_any_dir_not_r () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_w () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_rwx () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_exists () {
    for i in "$@" ; do
        if [ -e "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_null () {
    for i in "$@" ; do
        if [ -z "${i}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_r () {
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_w () {
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

# ##############################################################################

