#!/usr/bin/env bash

# Purpose: Rehash Daily Shells plugins

typeset PROGNAME=dshashplugins.sh


_load_ds () {
  typeset DS_CURRENT_HOME="${DS_HOME:-$HOME/.ds}"
  if [ -z "${DS_VERSION}" ] \
    && ! . "${DS_CURRENT_HOME}/ds.sh" "${DS_CURRENT_HOME}" >/dev/null 2>&1
  then
    echo 1>&2
    echo "Daily Shells could not be loaded. Fix it and call this again." 1>&2
    echo "Commands to install Daily Shells:" 1>&2
    echo "sh -c \"\$(curl -LSfs 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')\"" 1>&2
    echo "sh -c \"\$(wget -O - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')\"" 1>&2
    echo 1>&2
    exit 1
  fi
  if [ ! -d "$DS_HOME" ] ; then
    echo "${PROGNAME:+$PROGNAME: }FATAL: No DS_HOME='$DS_HOME' dir present." 1>&2
    exit 1
  fi
}
_load_ds


_set_global_defaults () {
  if [ -z "$DEV" ] && [ -d "$HOME/workspace" ] ; then
    export DEV="$HOME/workspace"
  fi
}


_hash_ds_plugins_locally () {
  typeset failures=false
  typeset plugin plugin_root

  for plugin in `cat "${DS_PLUGINS_FILE}"` ; do
    plugin_string="${plugin}"
    plugin_basename="${plugin_string##*/}"
    plugin_barename="${plugin_basename%.git}"

    for plugin_root in "$@" ; do
      echo
      echo "==> Daily Shells plugin '${plugin_string}' hashing from local dir: '${plugin_root}'..."
      echo
      if ls -1 -d "${plugin_root}/${plugin_barename}" >/dev/null 2>&1 ; then
        cp -a -v "${plugin_root}/${plugin_barename}"/*.sh "$DS_HOME/" 1>&2 || failures=true
        cp -a -v "${plugin_root}/${plugin_barename}"/*/ "$DS_HOME/" 1>&2 || failures=true
        # Uniquely append:
        if ! grep -q -w "${plugin_barename}" "${DS_PLUGINS_INSTALLED_FILE}" ; then
          echo "${plugin_barename}" >> "${DS_PLUGINS_INSTALLED_FILE}"
        fi
        continue
      fi
    done
  done

  if ${failures:-false} ; then
    echo "${PROGNAME:+$PROGNAME: }WARN: some copy jobs failed." 1>&2
    return 1
  fi
}


_hash_ds_plugins () {

  typeset failures=false

  if [ "$#" -gt 0 ] ; then
    _hash_ds_plugins_locally "$@"
    return $?
  fi

  echo
  echo "==> Daily Shells plugin hashing from '${DS_PLUGINS_FILE}'..."
  echo
  dsplugin.sh -f "${DS_PLUGINS_FILE}" || failures=true

  if ${failures:-false} ; then
    echo "${PROGNAME:+$PROGNAME: }WARN: some copy jobs failed." 1>&2
    return 1
  fi
}


_main () {
  _set_global_defaults
  _hash_ds_plugins "$@" || exit $?
  echo "${PROGNAME:+$PROGNAME: }COMPLETE"
  exit 0
}


_main "$@"
