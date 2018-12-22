# Daily Shells Library

# #############################################################################
# Globals

# DS_HOME
DS_HOME="${1:-${HOME%/}/.ds}"
# Squeeze slashes
if which tr >/dev/null 2>&1 ; then
  DS_HOME="$(echo "$DS_HOME" | tr -s /)"
fi
export DS_HOME

export DS_BACKUPS_DIR="${HOME}/.ds-backups"
export DS_CONF="${DS_HOME}/conf"
export DS_PLUGINS_FILE="${HOME}/.dsplugins"
export DS_PLUGINS_INSTALLED_FILE="${HOME}/.dsplugins-installed"
export DS_VERSION='v0.4.0 2018-01-05'

# #############################################################################
# DS core

touch "${DS_PLUGINS_FILE}"
touch "${DS_PLUGINS_INSTALLED_FILE}"
. "${DS_HOME}/ds00.sh" || return 100
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds0[1-9]*sh"

# #############################################################################
# Functions

if [[ $DS_VERBOSE = vv ]] ; then
  sourcefiles -t -v "${DS_HOME}/functions/*sh"
else
  sourcefiles -t "${DS_HOME}/functions/*sh"
fi

# #############################################################################
# DS additional core sources

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
