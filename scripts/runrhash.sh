#!/usr/bin/env bash

PROGNAME="runrhash.sh"

# Dotfiles deployment/rehashing functions and run recipes if any

_main () {
  typeset ignore_ssl_option

  if ${IGNORE_SSL:-false} ; then
    ignore_ssl_option='-k'
  fi

  if [ -d ~/.runr ] && ! mv -v ~/.runr ~/.runr.$(date '+%Y%m%d-%OH%OM%OS') ; then
    echo "${PROGNAME:+$PROGNAME: }FATAL: Could not backup '${HOME}/.runr'." 1>&2
    return 1
  fi

  if [ -d "$DEV"/runr ] && cp -a "${DEV}"/runr ~/.runr && [ -f ~/.runr/entry.sh ] ; then
    chmod 755 ~/.runr/entry.sh
    cd ~/.runr \
      && [[ $PWD = *.runr ]] \
      && bash -c "$(cat ./entry.sh)" entry.sh "$@"
  else
    bash -c "$(curl ${ignore_ssl_option} --tlsv1.3 -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
      || curl ${ignore_ssl_option} --tlsv1.3 -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
      entry.sh "$@"
  fi
}

_main "$@"
