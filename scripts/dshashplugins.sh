#!/usr/bin/env bash

# DS - Daily Shells

# Purpose:
# Rehash Daily Shells installation

typeset DS_CURRENT_HOME="${DS_HOME:-$HOME/.ds}"
typeset PROGNAME=dshashplugins.sh

_set_global_defaults () {
  if [ -z "$DEV" ] && [ -d "$HOME/workspace" ] ; then
    export DEV="$HOME/workspace"
  fi
}

_check_ds () {
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

_hash_ds_plugins () {

  typeset failures=false

  # Hash plugins:
  if [ -z "$DS_PLUGINS" ] ; then
    if [ -f ~/.dsplugins ] ; then
      export DS_PLUGINS="`cat ~/.dsplugins`"
    elif ls -1 -d "$DEV"/ds[a-z-]* >/dev/null 2>&1 ; then
      export DS_PLUGINS="`ls -1 -d "$DEV"/ds[a-z-]*`"
    fi
  fi
  for dsplugin in ${DS_PLUGINS} ; do
    echo "${PROGNAME:+$PROGNAME: }INFO: installing plugin '${dsplugin}'..."
    if [ -d "${dsplugin}" ] ; then
      cp -a "${dsplugin}"/*.sh "$DS_HOME/" 1>&2 || failures=true
      cp -a "${dsplugin}"/*/ "$DS_HOME/" 1>&2 || failures=true
    else
      dsplugin.sh "${dsplugin}" || failures=true
    fi
  done

  if ${failures:-false} ; then
    echo "${PROGNAME:+$PROGNAME: }WARN: some copy jobs failed." 1>&2
  fi
  echo "${PROGNAME:+$PROGNAME: }COMPLETE"
}

_set_global_defaults
_check_ds
_hash_ds_plugins
exit 0
