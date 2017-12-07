# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# ##############################################################################
# Post file

DS_LOADED=true

# Logging path:
: ${DS_ENV_LOG:=$HOME/log} ; export DS_ENV_LOG
[ -d "$DS_ENV_LOG" ] || mkdir -p "$DS_ENV_LOG" 2>/dev/null

# Post-calls
# Evaluate each line in the DS_POST_CALLS variable:

if [ -n "${DS_POST_CALLS}" ] ; then
    [ -n "$DS_VERBOSE" ] && echo "Running commands in DS_POST_CALLS ..." 1>&2
    while read nextcommand ; do
        eval "${nextcommand}" || DS_POST_STATUS=1
    done <<EOF
${DS_POST_CALLS:-:}
EOF
fi

# Display DS Information:
if [ -n "${DS_VERBOSE}" ] ; then
	echo && dsinfo
fi

return ${DS_POST_STATUS:-0}

