# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

export DS_HOME="${1:-${HOME%/}/.ds}"

export DS_CONF="${DS_HOME}/conf"
export DS_VERSION='==> DS v0.4.0 2018-01-05'

. "${DS_HOME}/ds00.sh" || return 10

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/functions/*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/env*sh"

echo
sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"
