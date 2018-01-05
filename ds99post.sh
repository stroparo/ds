# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# #############################################################################
# Post file

DS_LOADED=true

# Logging path:
: ${DS_ENV_LOG:=$HOME/log} ; export DS_ENV_LOG
if [ -d "${DS_ENV_LOG}" ] ; then
  mkdir -p "${DS_ENV_LOG}" 2>/dev/null
fi

# Post-calls
# Evaluate each line in the DS_POST_CALLS variable:

if [ -n "${DS_POST_CALLS}" ] ; then
  while read acommand ; do

    if [ -n "${DS_VERBOSE}" ] ; then
      echo "==> Next command:" 1>&2
      echo "${acommand}" 1>&2
    fi

    if ! eval "${acommand}" ; then
      DS_POST_STATUS=1
      echo "FATAL: failed command '${acommand}'" 1>&2
    fi

  done <<EOF
${DS_POST_CALLS:-:}
EOF
fi

# Display DS Information:
if [ -n "${DS_VERBOSE}" ] ; then
  echo 1>&2
  dsinfo 1>&2
fi

return ${DS_POST_STATUS:-0}
