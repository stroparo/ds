#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# cb function forked from original at:
#   http://madebynathan.com/2011/10/04/a-nicer-way-to-use-xclip/

# #############################################################################
# Globals

export PNAME="$(basename "$0")"
export USAGE="
NAME
    ${PNAME} - Copies a string to the clipboard.

SYNOPSIS
    ${PNAME} {string(s)}
    ${PNAME} {string(s)}
    echo <string> | ${PNAME}
    ${PNAME} < file
    ${PNAME} <<EOF

DESCRIPTION
    ${PNAME} will copy the arguments to the clipboard, but if there is no terminal
    attached it will get its data from stdin (pipe).
"

# #############################################################################
# Prep args

# Options:

export QUIET=false

OPTIND=1
while getopts ':hq' opt ; do
    case ${opt} in
        h) echo "$USAGE" ; exit ;;
        q) export QUIET=true;;
    esac
done
shift $((OPTIND - 1))

# #############################################################################
# Functions

cb () {
    typeset _col_end='\e[0m'
    typeset _scs_col="\e[0;32m"
    typeset _wrn_col='\e[1;31m'
    typeset _trn_col='\e[0;33m'
    typeset input

    if ! type xclip > /dev/null 2>&1; then

        sudo ${INSTPROG:-apt} install -y xclip || sudo dnf install -y xclip

        if ! type xclip > /dev/null 2>&1; then
            $QUIET || echo -e "$_wrn_col""You must have the 'xclip' program installed." 1>&2
        fi

    elif [[ "$USER" == "root" ]]; then

        # root doesn't have access to user xorg server
        $QUIET || echo -e "$_wrn_col""Must be regular user (not root) to copy a file to the clipboard.$_col_end" 1>&2

    else
        # If no tty, data should be available on stdin
        if ! [[ "$( tty )" == /dev/* ]]; then
            input="$(< /dev/stdin)"
        else
            input="$*"
        fi

        if [ -z "$input" ]; then
            $QUIET || echo "${USAGE}" 1>&2
        else # Copy to clipboard and print copied excerpt to the screen:
            echo -n "$input" | xclip -selection c || exit $?
            if [ ${#input} -gt 80 ] ; then
                input="$(echo ${input} | cut -c1-80)$_trn_col...$_col_end"
            fi
            $QUIET || echo -e "$_scs_col""Copied to clipboard:$_col_end ${input}" 1>&2
        fi
    fi
}

# #############################################################################
# Main

cb "$@"
exit "$?"
