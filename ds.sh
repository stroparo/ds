# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"

DS_CONF="${DS_HOME}/conf"
DS_VERSION='DS version 0.2.0 - 2017-01-01 00:00'

# Start

. "${DS_HOME}/ds00.sh" || return 10

if [ -n "$DS_VERBOSE" ] ; then
    echo 'Files to be sourced:' 1>&2
    ls -l "${DS_HOME}/functions/"*sh
    ls -l "${DS_HOME}/ds0"[1-9]*sh
    ls -l "${DS_HOME}/ds"[1-8][0-9]*sh
    ls -l "${DS_HOME}/ds"[A-Za-z]*sh
    ls -l "${DS_HOME}/sshagent.sh"
    ls -l "${DS_HOME}/ds99post.sh"
fi

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/functions/*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"
echo
sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"
