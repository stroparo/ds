# Call the custom configured routine responsible for synchronizing configuration

# Shortcut:
zc () {
  syncconf
}


syncconf () {
  if type "${SYNC_CONF_SCRIPT}" >/dev/null 2>&1 ; then
    "${SYNC_CONF_SCRIPT}"
  else
    echo "FATAL: $SYNC_CONF_SCRIPT (${SYNC_CONF_SCRIPT}) does not exist" 1>&2
    return 1
  fi
}
