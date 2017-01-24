# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"
export DS_VERBOSE
export DS_VERSION='DS version 0.2.0 - 2017-01-01 00:00'

# Start

. "${DS_HOME}/ds00.sh" || return 10

sourcefiles ${DS_VERBOSE:+-v} -q -t \
    "${DS_HOME}/functions/*sh" \
    "${DS_HOME}/ds0[1-9]*sh" \
    "${DS_HOME}/ds[1-8][0-9]*sh" \
    "${DS_HOME}/ds[A-Za-z]*sh" \
    "${DS_HOME}/ds99post.sh"

sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"

if [ -n "${DS_VERBOSE}" ] ; then dsinfo ; fi
