#!/usr/bin/env bash

PROGNAME="runr.sh"


_get_entry_online () {
  bash -c "$(curl ${ignore_ssl_option} ${DLOPTEXTRA} -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
    || curl ${ignore_ssl_option} ${DLOPTEXTRA} -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")"
}


_runr () {
  typeset ignore_ssl_option
  typeset runr_entry_code

  if ${IGNORE_SSL:-false} ; then
    ignore_ssl_option='-k'
  fi

  if ${DS_DEBUG:-false} && [ -f "$DEV/runr/entry.sh" ] ; then
    runr_entry_code="$(cat "$DEV/runr/entry.sh")"
  elif [ -f "${HOME}/.runr/entry.sh" ] ; then
    runr_entry_code="$(cat "${HOME}/.runr/entry.sh")"
  else
    runr_entry_code="$(_get_entry_online)"
  fi

  if [ -n "${runr_entry_code}" ] ; then
    bash -c "${runr_entry_code}" entry.sh "$@"
  else
    echo "${PROGNAME:+$PROGNAME: }FATAL: No runr entry script code could be retrieved." 1>&2
    return 1
  fi
}


_runr "$@"

