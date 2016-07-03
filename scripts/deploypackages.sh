#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# Purpose:
# This script deploys packages from-to the given directories.

usage="$(basename "$0") [-c] [-x {exclude-expression}] {packages-path} {destination}

Options:
-c  Asks for prior user confirmation.
"

# ##############################################################################
# Functions

deploypackages () {

    typeset oldind="${OPTIND}"
    typeset pname=deploypackages

    typeset deploypath
    typeset exclude
    typeset pkgspath
    typeset userconfirm

    OPTIND=1
    while getopts ':cx:' opt ; do
        case "${opt}" in
        c) userconfirm=true ;;
        x) exclude="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    pkgspath="${1}"
    deploypath="${2}"

    if ${userconfirm:-false} ; then
        userconfirm "Deploy packages from '${pkgspath}' ?" || return
    fi

    if [ -z "$(ls -1 "${pkgspath}" 2>/dev/null | egrep '([.]7z|[.]zip|bz2|gz)$')" ] ; then
        elog -n "$pname" -f "No packages in '${pkgspath}'."
        return 1
    fi

    elog -n "$pname" "Packages path '${pkgspath}' .."
    elog -n "$pname" ".. deploying to '${deploypath}' .."

    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*.7z 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*.zip 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*bz2 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*gz 2>/dev/null)

    elog -n "$pname" 'Complete.'
}

# ##############################################################################
# Main

deploypackages "$@"
exit "$?"
