# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# ##############################################################################
# Post file

# ##############################################################################
# Globals

DS_GLOB="ds.sh ds[0-9]*sh aliases.sh sshagent.sh"
DS_LOADED=true

# ##############################################################################
# Main

unalias d 2>/dev/null

chmodshells -a -p "${DS_HOME}/bin" "${DS_HOME}/scripts"

runcommands "${DS_POST_CALLS}"
