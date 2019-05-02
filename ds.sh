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
  SOURCE_FUNCTIONS_OPTIONS="-v"
fi

if [ -n "${DS_SOURCES_FUNCTIONS}" ] ; then
  for functions_file in $(echo ${DS_SOURCES_FUNCTIONS}) ; do
    sourcefiles ${SOURCE_FUNCTIONS_OPTIONS} "${DS_HOME}/functions/${functions_file%.sh}.sh"
  done
else
  sourcefiles -t ${SOURCE_FUNCTIONS_OPTIONS} "${DS_HOME}/functions/*sh"
fi


# #############################################################################
# DS additional core sources

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[1-8][0-9]*sh"
sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds[A-Za-z]*sh"
sourcefiles -v "${DS_HOME}/sshagent.sh"

# #############################################################################
# Environments

if [ -n "${DS_SOURCES_ENVIRONMENTS}" ] ; then
  for env in $(echo ${DS_SOURCES_ENVIRONMENTS}) ; do
    env="${env#env}"
    sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/env${env%.sh}.sh"
  done
else
  sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/env*sh"
fi

# #############################################################################
# Post DS loading calls

sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds99post.sh"

# #############################################################################
