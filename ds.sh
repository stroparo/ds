# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

# #############################################################################
# Globals

export DS_HOME="${1:-${HOME%/}/.ds}"

export DS_CONF="${DS_HOME}/conf"
export DS_VERSION='v0.4.0 2018-01-05'

# #############################################################################
# DS core

. "${DS_HOME}/ds00.sh" || return 10

# #############################################################################
# Functions

if [[ $DS_VERBOSE = vv ]] ; then
  sourcefiles -t -v "${DS_HOME}/functions/*sh"
else
  sourcefiles -t "${DS_HOME}/functions/*sh"
fi

# #############################################################################
# DS additional core sources

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"

# #############################################################################
# Environments

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/env*sh"

# #############################################################################
# Miscellaneous

sourcefiles -v "${DS_HOME}/sshagent.sh"

# #############################################################################
# Post DS loading calls

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"

# #############################################################################
