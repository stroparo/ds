#!/usr/bin/env sh

# Globals:
INSTALL_DIR=${1:-$HOME/.ds}
BACKUP_FILENAME="${INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"
DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'

# Param DL_PROG - what program to use for downloading:
DL_PROG="wget"
OUT_OPTION='-O'
which curl &> /dev/null && DL_PROG="curl" && OUT_OPTION='-fLSso'

# Backup:
mv -f "${INSTALL_DIR}" "${BACKUP_FILENAME}" >/dev/null 2>&1
if [ -e "${INSTALL_DIR}" ] && [ ! -e "${BACKUP_FILENAME}" ] ; then
  echo "FATAL: could not backup DS to '${BACKUP_FILENAME}'" 1>&2
  exit 1
fi

# Download the main package and install:
$DL_PROG 'https://github.com/stroparo/ds/archive/master.zip' \
  $OUT_OPTION "${INSTALL_DIR}.zip" \
  && unzip "${INSTALL_DIR}.zip" -d "$HOME" \
  && mv "$HOME/ds-master" "${INSTALL_DIR}"

if [ $? -ne 0 ] ; then
  echo "FATAL: installation error." 1>&2
  
  if ! mv -f "${BACKUP_FILENAME}" "${INSTALL_DIR}" >/dev/null 2>&1 ; then
    echo "INFO: backup restored." 1>&2
  else
    echo "FATAL: could not restore the backup at '${BACKUP_FILENAME}'." 1>&2
  fi
  
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
  echo "FATAL: could not load DS." 1>&2
  exit 99
fi
