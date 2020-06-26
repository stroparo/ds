dsplug () {
  for plugin in "$@" ; do
    plugin_basename="${plugin%.git}"
    plugin_basename="${plugin##*/}"
    if ! grep -q "${plugin_basename}" "${DS_PLUGINS_INSTALLED_FILE}" && dsplugin.sh "${plugin}" ; then
      dsload
    fi
  done
}
