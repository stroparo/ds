#!/usr/bin/env sh

# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

# #############################################################################
# Fixed globals

USAGE="[-h] [-f]"

TEMP_DIR=$HOME

DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'
DS_PKG_URL="https://github.com/stroparo/ds/archive/master.zip"


# #############################################################################
# Options

OPTIND=1
while getopts ':fh' option ; do
  case "${option}" in
    f) FORCE=true;;
    h) echo "$USAGE"; exit;;
  esac
done
shift "$((OPTIND-1))"

# #############################################################################
# Dynamic globals

INSTALL_DIR=${1:-$HOME/.ds}
BACKUP_FILENAME="${INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"

# Setup the downloader program (curl/wget)
if which curl >/dev/null 2>&1 ; then
  export DLPROG=curl
  export DLOPT='-LSfs'
  export DLOUT='-o'
  if ${FORCE:-false} ; then
    export DLOPT="-k $DLOPT"
  fi
elif which wget >/dev/null 2>&1 ; then
  export DLPROG=wget
  export DLOPT=''
  export DLOUT='-O'
else
  echo "FATAL: curl and wget missing" 1>&2
  exit 1
fi

# #############################################################################
# Checks

# Error exit if installation path already occupied:
if [ -d "$INSTALL_DIR" ] ; then
  echo "FATAL: This is a first setup only script and '${INSTALL_DIR}' dir already exists" 1>&2
  echo "       ... if you want to proceed first remove it or move it out of there" 1>&2
  echo "       ... and rerun this" 1>&2
  exit 1
fi

# #############################################################################
# Install

# Download the main package and install:
"$DLPROG" ${DLOPT} ${DLOUT} "${INSTALL_DIR}.zip" "$DS_PKG_URL" \
  && unzip "${INSTALL_DIR}.zip" -d "$TEMP_DIR" \
  && mv "$TEMP_DIR/ds-master" "${INSTALL_DIR}"
INST_RESULT=$?

# #############################################################################
# Verification

if [ $INST_RESULT -ne 0 ] ; then
  echo "FATAL: installation error." 1>&2
  rm -f -r "$INSTALL_DIR"
  exit $INST_RESULT
fi

. "${INSTALL_DIR}/ds.sh" "${INSTALL_DIR}" >/dev/null 2>&1

if [ -n "${DS_LOADED}" ] ; then
  touch "$HOME/.bashrc" "$HOME/.zshrc"
  appendunique -n "$DS_LOAD_CODE" "$HOME/.bashrc" "$HOME/.zshrc"
  echo "INFO: DS installed." 1>&2
else
  echo "FATAL: could not load DS." 1>&2
  exit 99
fi

# #############################################################################
