# DRYSL (DRY Scripting Library)

# #############################################################################
# Post file

DS_LOADED=true

# Logging path:
: ${DS_ENV_LOG:=$HOME/log} ; export DS_ENV_LOG
if [ ! -d "${DS_ENV_LOG}" ] ; then
  mkdir -p "${DS_ENV_LOG}" 2>/dev/null
fi

# Post-calls
# Evaluate each line in the DS_POST_CALLS variable:

if [ -n "${DS_POST_CALLS}" ] ; then
  DS_POST_STATUS=0

  while read acommand ; do

    if [ -n "${DS_VERBOSE}" ] ; then
      echo ${BASH_VERSION:+-e} "==> Next command in DS_POST_CALLS: \c" 1>&2
      echo "${acommand}" 1>&2
    fi

    if ! eval "${acommand}" ; then
      DS_POST_STATUS=1
      echo "ERROR: Command '${acommand}'" 1>&2
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
