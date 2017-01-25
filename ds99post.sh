# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# ##############################################################################
# Post file

# ##############################################################################
# Globals

export DS_GLOB="ds*sh aliases.sh ee.sh setup.sh sshagent.sh"
export DS_LOADED=true
: ${DS_CONF:=${DS_HOME}/conf} ; export DS_CONF

# ##############################################################################
# Main

# Protect names of important DS functions against custom prior aliases:
unalias d 2>/dev/null

# Post-calls: Evaluate each line in the DS_POST_CALLS variable:
if [ -n "${DS_POST_CALLS}" ] ; then

    echo ${BASH_VERSION:+-e} "\nRunning commands in DS_POST_CALLS ..." 1>&2

    while read nextcommand ; do
        eval "${nextcommand}"
    done <<EOF
${DS_POST_CALLS:-:}
EOF
fi
