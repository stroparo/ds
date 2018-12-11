#!/bin/bash

# Daily Shells Library

# #############################################################################
# Fixed globals

USAGE="[-h] [-f]"

DS_PKG_URL="https://bitbucket.org/stroparo/ds/get/master.zip"
DS_PKG_URL_ALT="https://github.com/stroparo/ds/archive/master.zip"
TEMP_DIR=$HOME

# #############################################################################
# Options

OPTIND=1
while getopts ':fh' option ; do
  case "${option}" in
    f)
      FORCE=true
      IGNORE_SSL=true
      ;;
    h)
      echo "${USAGE}"
      exit
      ;;
  esac
done
shift "$((OPTIND-1))"

# #############################################################################
# Dynamic globals

INSTALL_DIR="$(echo "${1:-\${HOME\}/.ds}" | tr -s /)"
DS_LOAD_CODE="[ -r \"${INSTALL_DIR}/ds.sh\" ] && source \"${INSTALL_DIR}/ds.sh\" \"${INSTALL_DIR}\" 1>&2"
INSTALL_DIR="$(eval echo "\"${INSTALL_DIR}\"")"
BACKUP_FILENAME="${INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"

# Setup the downloader program (curl/wget)
export DLOPTEXTRA
if which curl >/dev/null 2>&1 ; then
  export DLPROG=curl
  export DLOPT='-LSfs'
  export DLOUT='-o'
  if ${IGNORE_SSL:-false} ; then
    export DLOPT="-k ${DLOPT}"
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

# Skip this setup altogether if installation path already occupied:
if [ -d "$INSTALL_DIR" ] ; then
  echo "SKIP: '${INSTALL_DIR}' dir already exists" 1>&2
  exit
fi

# #############################################################################
# Install

if [ -e ./ds.sh ] && [ "${PWD}" != "${INSTALL_DIR}" ] ; then
  echo "Daily Shells setup from local dir '${PWD}'..." 1>&2
  mkdir "${INSTALL_DIR}" \
    && cp -f -R -v "${PWD}"/* "${INSTALL_DIR}"/
  INST_RESULT=$?
  echo "INFO: Daily Shells setup dir used was '${PWD}'"
else
  echo "Daily Shells setup: downloading and installing..." 1>&2
  ("$DLPROG" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${INSTALL_DIR}.zip" "${DS_PKG_URL}" \
    || "$DLPROG" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${INSTALL_DIR}.zip" "${DS_PKG_URL_ALT}") \
    && unzip "${INSTALL_DIR}.zip" -d "$TEMP_DIR"

  # Old: mv "${TEMP_DIR}/ds-master" "${INSTALL_DIR}"
  DL_RESULT=$?
  if [ $DL_RESULT -eq 0 ] ; then
    zip_dir=$(unzip -l "${INSTALL_DIR}.zip" | head -5 | tail -1 | awk '{print $NF;}')
    echo "Zip dir: '${zip_dir}'" 1>&2
    mv -f -v "$TEMP_DIR"/"${zip_dir}" "${INSTALL_DIR}" 1>&2
    INST_RESULT=$?
  else
    INST_RESULT=${DL_RESULT}
  fi
fi

# #############################################################################
# Verification

if [ ${INST_RESULT} -ne 0 ] ; then
  echo "FATAL: installation error." 1>&2
  rm -f -r "${INSTALL_DIR}"
  exit ${INST_RESULT}
fi

# #############################################################################
# Cleanup installed plugins list file

# At this point this fresh installation succeeded, so this
#   guarantees there are no status files from previous
#   installations:
eval $(grep DS_PLUGINS_INSTALLED_FILE= "${INSTALL_DIR}/ds.sh")
echo "INFO: Plugins installed file: '${DS_PLUGINS_INSTALLED_FILE}'"
ls -l "${DS_PLUGINS_INSTALLED_FILE}" 2>/dev/null
if [ -f "${DS_PLUGINS_INSTALLED_FILE}" ] ; then
  rm -f -v "${DS_PLUGINS_INSTALLED_FILE}"
fi

# #############################################################################
echo "INFO: Loading and setting shell profiles up..."

. "${INSTALL_DIR}/ds.sh" "${INSTALL_DIR}"

if [ -n "${DS_LOADED}" ] ; then
  touch "${HOME}/.bashrc" "${HOME}/.zshrc"
  appendunique -n "${DS_LOAD_CODE}" "${HOME}/.bashrc" "${HOME}/.zshrc"
  echo "INFO: DS installed." 1>&2
else
  echo "FATAL: DS installed but could not load it." 1>&2
  exit 99
fi

# #############################################################################
