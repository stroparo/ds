#!/usr/bin/env sh

# Globals:
INSTALL_DIR=${1:-$HOME/.ds}
TEMP_DIR=$HOME
BACKUP_FILENAME="${INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"
DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'

# Param downloader program (curl/wget)
DL_PROG="wget"
DL_OPTS=''
OUT_OPTION='-O'
if which curl &> /dev/null ; then
  DL_PROG="curl"
  DL_OPTS='-LSfs'
  OUT_OPTION='-o'
fi
! which wget \
  && ! which curl \
  && echo "FATAL: curl or wget missing" 1>&2 \
  && exit 1

# Error exit if installation path already occupied:
if [ -d "${INSTALL_DIR}" ] ; then
  echo "FATAL: This is a first setup only script and '${INSTALL_DIR}' dir already exists" 1>&2
  echo "       ... if you want to proceed first remove it or move it out of there" 1>&2
  echo "       ... and rerun this" 1>&2
  exit 1
fi

# Download the main package and install:
$DL_PROG 'https://github.com/stroparo/ds/archive/master.zip' \
  $DL_OPTS $OUT_OPTION "${INSTALL_DIR}.zip" \
  && unzip "${INSTALL_DIR}.zip" -d "$TEMP_DIR" \
  && mv "$TEMP_DIR/ds-master" "${INSTALL_DIR}"

if [ $? -ne 0 ] ; then
  echo "FATAL: installation error." 1>&2
  rm -f -r "${INSTALL_DIR}"
  exit 1
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
