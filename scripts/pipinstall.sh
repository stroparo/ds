#!/usr/bin/env bash

# Daily Shells Library

# #############################################################################
# Globals

PROGNAME="pipinstall.sh"
USAGE="$PROGNAME [-e venv] [{pip package|file containing a list of pip packages}+]

REMARK
If -e venv option, then use pyenv to activate it (fail on pyenv abscence)
"

# #############################################################################
# Routines

pipinstall () {
  typeset venv
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':e:h' option ; do
    case "${option}" in
      e)
        venv="${OPTARG}"
        if ! which pyenv >/dev/null 2>&1 ; then
          echo "${PROGNAME:+$PROGNAME: }FATAL: a virtualenv was specified but no pyenv is available to activate it." 1>&2
          return 1
        fi
        ;;
      h)
        echo "$USAGE"
        exit
        ;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  pip --version > /dev/null || return $?

  if [ -n "${venv}" ] ; then
    : ${WORKON_HOME:=${HOME}/.ve} ; export WORKON_HOME
    : ${PROJECT_HOME:=${HOME}/workspace} ; export PROJECT_HOME
    export PATH="${HOME}/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"

    if ! pyenv activate "${venv}" ; then
      echo "${PROGNAME:+$PROGNAME: }FATAL: Could not switch to the '${venv}' virtualenv." 1>&2
      return 1
    fi
  fi

  for pkg in "$@" ; do
    if [ -f "${pkg}" ] ; then
      for readpkg in $(cat "${pkg}") ; do
        echo ${BASH_VERSION:+-e} "\n==> pip install '$readpkg'..."
        pip install "$readpkg"
      done
    else
      echo ${BASH_VERSION:+-e} "\n==> pip install '${pkg}'..."
      pip install "${pkg}"
    fi
  done
}

# #############################################################################
# Main

pipinstall "$@" || exit "$?"
