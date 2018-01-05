# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"

export DS_CONF="${DS_HOME}/conf"
export DS_VERSION='DS version 0.4.0 - 2018-01-05 21:40 UTC'

. "${DS_HOME}/ds00.sh" || return 10

if [[ $DS_VERBOSE = vv ]] ; then
    echo 'Files to be sourced:' 1>&2
    ls -l "${DS_HOME}/functions/"*sh
    ls -l "${DS_HOME}/ds0"[1-9]*sh
    ls -l "${DS_HOME}/ds"[1-8][0-9]*sh
    ls -l "${DS_HOME}/ds"[A-Za-z]*sh
    ls -l "${DS_HOME}/env"*sh
    ls -l "${DS_HOME}/sshagent.sh"
    ls -l "${DS_HOME}/ds99post.sh"
fi

# functions
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/functions/*sh"

# ds01*..ds09*:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"

# ds10*..ds89* (do not touch 90's as these are reserved):
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"

# ds[letters]*:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"

# env*:
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/env*sh"

echo
sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"
