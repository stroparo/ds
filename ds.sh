#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# DS reserved objects

export DS_HOME="${1:-${HOME%/}/.ds}"
export DS_VERBOSE
export DS_VERSION='DS version 0.1.0 - 2016-01-18 22:30'

# Function dsversion - displays the Daily Shells header and version.
#  Stdout is fully redirected to stderr.
unset dsversion
dsversion () {
    echo "Daily Shells - ${DS_VERSION}" 1>&2
}

# Function dshelp - displays the Daily Shells help information.
#  Stdout is fully redirected to stderr.
unset dshelp
dshelp () {
    echo 'DS - Daily Shells Library - Help

Commands:

dshelp:     displays this help messsage.
dsinfo:     displays environment information.
dsversion:  displays the version of this Daily Shells instance.
' 1>&2
}

# Function dsinfo - this displays DS environment information.
#  It might be overriden by your own fork.
#  Stdout is fully redirected to stderr.
unset dsinfo
dsinfo () {
    dsversion
    echo "DS_HOME='${DS_HOME}'" 1>&2
}

# ##############################################################################
# Stage for removal

# Functions pnamesave and pnamerestore  - handle pname param backup and restore.
#  Used at the beginning and end of routines such as functions.
#  Also the pname param is used by some functions like elog.
unset pnamesave pnamerestore
pnamesave () { oldpname="$pname" ; }
pnamerestore () { pname="$oldpname" ; }

# ##############################################################################
# Main

# DS init:
. "${DS_HOME}/dsbase.sh" || return 10
[ -n "${DS_VERBOSE}" ] && dsinfo 1>&2
sourcefiles "${DS_HOME}/aliases*sh" || return 20
aliasnoext "${DS_HOME}/scripts"
sourcefiles ${DS_VERBOSE:+-v} -t -n 'DS specialized' "${DS_HOME}/ds4[a-z]*sh"
elog -v 'DONE'

# Enhancing profiles:
sourcefiles ${DS_VERBOSE:+-v} -t -n 'Custom environments' "${DS_HOME}/env*sh"
elog -v 'DONE'
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
elog -v 'DONE'

# DS init post-routines:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/dspost.sh"
elog -v 'DONE'
