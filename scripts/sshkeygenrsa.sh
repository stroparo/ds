#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

sshkeygenrsa () {
  # Info: Generate id_rsa if none present for the current user.
  # Syntax: {comment} [keypath]

  typeset comment="$1"
  typeset keypath="${2:-${HOME}/.ssh/id_rsa}"

  while [ -z "${comment}" ] ; do
    echo 'SSH key comment (email, name or whatever)'
    read comment
  done

  while [ -e "${keypath}" ] ; do
    echo "Key '${keypath}' already exists, type another path"
    read keypath
  done

  if [[ $keypath = $HOME/.ssh* ]] && [ ! -d "$HOME/.ssh" ] ; then
    mkdir "$HOME/.ssh"
  fi

  if [ ! -d "$(dirname "$keypath")" ] ; then
    echo "FATAL: No directory available to store '$keypath'." 1>&2
    return 1
  fi

  ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}"
}

sshkeygenrsa "$@" || return $?
