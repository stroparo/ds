#!/usr/bin/env bash

PROGNAME="runrhash.sh"

# Dotfiles deployment/rehashing functions and run recipes if any

_runrhash_helper () {
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
    bash -c "$(curl -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
      || curl -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
      entry.sh "$@"
  fi
}

_runrhash_helper "$@"
