# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"
export DS_VERBOSE
export DS_VERSION='DS version 0.1.0 - 2016-01-18 22:30'

dsversion () { echo "Daily Shells - ${DS_VERSION}" 1>&2 ; }
dsinfo () { dsversion ; echo "DS_HOME='${DS_HOME}'" 1>&2 ; }

dshelp () {
    echo 'DS - Daily Shells Library - Help

Commands:

dshelp:     displays this help messsage.
dsinfo:     displays environment information.
dsversion:  displays the version of this Daily Shells instance.
' 1>&2
}

# ##############################################################################

. "${DS_HOME}/ds00.sh" || return 10

if [ -n "${DS_VERBOSE}" ] ; then dsinfo 1>&2 ; fi

sourcefiles ${DS_VERBOSE:+-v} -q -t \
    "${DS_HOME}/functions/*sh" \
    "${DS_HOME}/ds0[1-9]*sh" \
    "${DS_HOME}/ds[1-8][0-9]*sh" \
    "${DS_HOME}/ds[A-Za-z]*sh" \
    "${DS_HOME}/ds99post.sh"

sourcefiles ${DS_VERBOSE:+-v} -q "${DS_HOME}/aliases*sh"
sourcefiles ${DS_VERBOSE:+-v} -q "${DS_HOME}/ee.sh"
sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"
