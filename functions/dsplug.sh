dsplug () {
  for plugin in "$@" ; do
    plugin_basename="${plugin%.git}"
    plugin_basename="${plugin##*/}"

    was_already_installed=false
    if grep -q "${plugin_basename}" "${DS_PLUGINS_INSTALLED_FILE}" ; then
      was_already_installed=true
    fi

    if dsplugin.sh "${plugin}" && ! ${was_already_installed} ; then
      dsload
    fi
  done
}
