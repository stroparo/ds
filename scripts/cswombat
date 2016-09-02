#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# ##############################################################################
# Globals

export PNAME="$(basename "$0")"
export USAGE="
NAME
    ${PNAME} - Customizes sublime text wombat theme (if present).

SYNOPSIS
    ${PNAME} [sublime text conf/packages directory]

DESCRIPTION

"

# ##############################################################################
# Prep args

# Options:

OPTIND=1
while getopts ':h' opt ; do
    case ${opt} in

    h) echo "$USAGE" ; exit ;;

    esac
done
shift $((OPTIND - 1))

# ##############################################################################
# Prep

# Prep commands HERE...

# ##############################################################################
# Functions

# Set SBCONF to point to sublime-text configuration directory.
# Usage: [sublime_text path, mandatory for cygwin.]
setsublimeconf () {
    typeset sbconfs sbconfsel sbpath
    export SBCONF=''

    if [[ "$(uname -a)" = *[Ll]inux* ]] || \
        [[ "$(uname -a)" = *[Db]ebian* ]] || \
        [[ "$(uname -a)" = *[Uu]buntu* ]]
    then
        sbconfs="$(find ~/.[a-z]* -type d -name '*subl*' | grep -v 'oh.*my.*zsh')"

        if [ -z "$sbconfs" ] ; then
            echo 'setsublimeconf: INFO: Launching sublime to try and create config directory..'
            subl
            echo "setsublimeconf: INFO: Try running this setup again after sublime has been launched.."
            return 1
        fi

        if [ $(echo "$sbconfs" | wc -l) -gt 1 ] ; then

            select sbconfsel in ${sbconfs} ; do
                if [ -d "$sbconfsel" ] ; then
                    SBCONF="${sbconfsel}"
                    break
                fi
            done
        else
            SBCONF="${sbconfs}"
        fi
    elif [[ "$(uname -a)" = *[Cc]ygwin* ]] ; then
        if [ -n "$1" ] ; then
            sbpath="$1"
        else
            echo 'Enter sublime_text program path (in cygpath form):'
            read sbpath
        fi
        SBCONF="$(dirname "${sbpath}")/Data"
    else
        echo "setsublimeconf: SKIP: Only Cygwin and Linux are supported." 1>&2
        return 1
    fi
    export SBCONF
}

prep () {
    export SBCONF="$1"

    if [ -z "$SBCONF" ] ; then
        setsublimeconf
    fi

    if [ ! -d "${SBCONF}" ] ; then
        echo "${PNAME}: FATAL: Conf dir '${SBCONF}' does not exist.. (When omitted this program tries to find it.)" 1>&2
        exit 1
    fi

    export WOMBATPKG="${SBCONF}/Installed Packages/Wombat Theme.sublime-package"

    if [ ! -f "${WOMBATPKG}" ] ; then
        echo "${PNAME}: SKIP: No wombat package '${WOMBATPKG}'." 1>&2
        exit
    fi
}

main () {

    cd "$(dirname "${WOMBATPKG}")" || exit 1

    unzip "${WOMBATPKG}" 'Wombat.sublime-theme' || exit 1

    awk '
        BEGIN { count = 0; }

        /^[/][/] TAB LABELS/ { tablabels = 1; }

        /"fg":/ {
            if (tablabels) {
                count++;
                if (count == 1) {
                    sub(/[[].*[]]/, "[190, 190, 190]");
                } else if (count == 2) {
                    sub(/[[].*[]]/, "[200, 220, 200]");
                } else if (count == 3) {
                    sub(/[[].*[]]/, "[220, 240, 220]");
                }
            }
        }

        { print; }
    ' 'Wombat.sublime-theme' \
    > 'Wombat.sublime-theme_'

    mv -f 'Wombat.sublime-theme_' 'Wombat.sublime-theme' || exit 1

    zip -u "${WOMBATPKG}" 'Wombat.sublime-theme' || exit 1

    echo '${PNAME}: INFO: Process complete.'
    echo ''
}

# ##############################################################################
# Main

prep "$@"
main "$@"
exit "$?"
