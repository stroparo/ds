#!/usr/bin/env bash

PROGNAME="dsconfsgit.sh"

# Daily Shells configuration scripts - Git

echo
echo "${PROGNAME:+$PROGNAME: }INFO: Applying Daily Shells Git configurations..." 1>&2
echo

if . "${DS_HOME}/functions/git.sh" ; then
  gitenforcemyuser
fi

for git_script in "${DS_HOME:-$HOME/.ds}"/*/*conf-git.sh ; do
  bash "${git_script}"
done
