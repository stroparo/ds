#!/usr/bin/env bash

PROGNAME="runr.sh"


_runr () {
  typeset ignore_ssl_option
  typeset script_content

  if ${IGNORE_SSL:-false} ; then
    ignore_ssl_option='-k'
  fi

  if [ -f ~/.runr/entry.sh ] ; then
    script_content="$(cat ~/.runr/entry.sh)"
  else
    script_content="$(bash -c "$(curl ${ignore_ssl_option} ${DLOPTEXTRA} -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
                      || curl ${ignore_ssl_option} ${DLOPTEXTRA} -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")")"
  fi
  bash -c "${script_content}" entry.sh "$@"
}


_runr "$@"

