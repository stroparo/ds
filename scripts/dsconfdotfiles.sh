#!/usr/bin/env bash

PROGNAME="dsconfdotfiles.sh"

echo
echo "${PROGNAME:+$PROGNAME: }INFO: Applying DRYSL (DRY Scripting Library) config recipes for dotfiles selects..." 1>&2
echo

for filename in "${DS_HOME:-$HOME/.ds}"/*/*conf-dotfiles.sh ; do
  if [ -f "${filename}" ] ; then
    bash "${filename}"
  fi
done
