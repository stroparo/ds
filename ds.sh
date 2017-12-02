# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"

DS_CONF="${DS_HOME}/conf"
DS_VERSION='DS version 0.3.0 - 2017-12-02 00:00'

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

# ds01*..ds09*:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"

# ds10*..ds89* (do not touch 90's as these are reserved):
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"

# ds[letters]*:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"

echo
sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"
