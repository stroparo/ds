#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

sshkeygenrsa () {
  # Info: Generate id_rsa if none present for the current user.

  typeset comment="${1:-${USER}@$(hostname)}"
  typeset keydir
  typeset keypath="${2:-${HOME}/.ssh/id_rsa}"
  typeset usage="Usage: {comment} [keypath]"

  while [[ $- = *i* ]] && [ -z "${comment}" ] ; do
    echo 'SSH key comment (email, name or whatever)'
    read comment
  done

  while [[ $- = *i* ]] && [ -e "${keypath}" ] ; do
    echo "Key '${keypath}' already exists, type another path"
    read keypath
  done
  # Non interactive, might still exist...
  if [ -e "${keypath}" ] ; then
    echo "FATAL: Key '${keypath}' already exists" 1>&2
    echo "${usage}" 1>&2
    exit 1
  fi

  keydir="$(dirname "${keypath}")"

  if [ ! -d "${keydir}" ] ; then

    mkdir "${keydir}"

    if [ ! -d "${keydir}" ] ; then
      echo "FATAL: Could not create dir '${keydir}'." 1>&2
      return 1
    fi
  fi

  ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" \
    && chmod 700 "${keypath}" \
    && echo \
    && echo "==> '${keypath}' file:" \
    && ls -l "${keypath}" \
    && echo \
    && echo "==> '${keypath}' contents:" \
    && cat "${keypath}"
}

sshkeygenrsa "$@" || exit $?
