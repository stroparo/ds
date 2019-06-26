#!/usr/bin/env bash

PROGNAME="dsconfsgit.sh"

# Daily Shells configuration scripts for Git

echo
echo "${PROGNAME:+$PROGNAME: }INFO: Applying Daily Shells Git configurations..." 1>&2
echo

if . "${DS_HOME}/functions/git.sh" ; then
  gitenforcemyuser
fi

for git_script in "${DS_HOME:-$HOME/.ds}"/*/*conf-git.sh ; do
  if [ -f "${git_script}" ] ; then
    bash "${git_script}"
  fi
done
