#!/usr/bin/env sh

INSTALL_DIR=${1:-$HOME/.ds}
DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'
BACKUP_FILENAME="${INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"

# CURL/WGET
DL_PROG="wget"
OUT_OPTION='-O'
which curl &> /dev/null && DL_PROG="curl" && OUT_OPTION='-o'

mv -f "${INSTALL_DIR}" "${BACKUP_FILENAME}"
$DL_PROG 'https://github.com/stroparo/ds/archive/master.zip' \
  $OUT_OPTION "${INSTALL_DIR}.zip" \
  && unzip "${INSTALL_DIR}.zip" -d "$HOME" \
  && mv "$HOME/ds-master" "${INSTALL_DIR}"

if [ $? -ne 0 ] ; then
  echo "FATAL: installation." 1>&2
  mv -f "${BACKUP_FILENAME}" "${INSTALL_DIR}" && echo "INFO: backup restored." 1>&2
  exit 1
else
  rm -rf "${BACKUP_FILENAME}"
fi

. "${INSTALL_DIR}/ds.sh" "${INSTALL_DIR}" >/dev/null 2>&1

if [ -n "${DS_LOADED}" ] ; then
  touch "$HOME/.bashrc" "$HOME/.zshrc"
  appendunique -n "$DS_LOAD_CODE" "$HOME/.bashrc" "$HOME/.zshrc"
  echo "INFO: DS installed." 1>&2
else
  echo "FATAL: DS not loaded." 1>&2
  exit 99
fi
