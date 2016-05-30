# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Post file

# Params:
DS_LOADED=true

# Aliases:
unalias d 2>/dev/null

# Calls:
aliasnoext "${DS_HOME}/scripts"
runcommands "${DS_POST_CALLS}"
