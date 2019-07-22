#!/usr/bin/env bash

PROGNAME="dsconfgit.sh"

echo
echo "${PROGNAME:+$PROGNAME: }INFO: Applying Daily Shells config recipes for Git..." 1>&2
echo

if . "${DS_HOME}/functions/git.sh" ; then
  gitenforcemyuser
fi

for filename in "${DS_HOME:-$HOME/.ds}"/*/*conf-git.sh ; do
  if [ -f "${filename}" ] ; then
    bash "${filename}"
  fi
done
