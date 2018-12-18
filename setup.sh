#!/bin/bash

# Daily Shells Library

PROGNAME="setup.sh"

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

DS_INSTALL_DIR="$(echo "${1:-\${HOME\}/.ds}" | tr -s /)"
DS_LOAD_CODE="[ -r \"${DS_INSTALL_DIR}/ds.sh\" ] && source \"${DS_INSTALL_DIR}/ds.sh\" \"${DS_INSTALL_DIR}\" 1>&2"
DS_INSTALL_DIR="$(eval echo "\"${DS_INSTALL_DIR}\"")"
BACKUP_FILENAME="${DS_INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"

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
  echo "${PROGNAME} (ds): FATAL: curl and wget missing" 1>&2
  exit 1
fi

# #############################################################################
# Checks

# Skip this setup altogether if installation path already occupied:
if [ -d "$DS_INSTALL_DIR" ] ; then
  echo "${PROGNAME} (ds): SKIP: '${DS_INSTALL_DIR}' dir already exists" 1>&2
  exit
fi

# #############################################################################
# Install

if [ -e ./ds.sh ] && [ "${PWD}" != "${DS_INSTALL_DIR}" ] ; then
  echo "Daily Shells setup from local dir '${PWD}'..." 1>&2
  mkdir "${DS_INSTALL_DIR}" \
    && cp -f -R -v "${PWD}"/* "${DS_INSTALL_DIR}"/
  INST_RESULT=$?
  echo "${PROGNAME} (ds): INFO: Daily Shells setup dir used was '${PWD}'"
else
  echo "Daily Shells setup: downloading and installing..." 1>&2
  ("$DLPROG" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${DS_INSTALL_DIR}.zip" "${DS_PKG_URL}" \
    || "$DLPROG" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${DS_INSTALL_DIR}.zip" "${DS_PKG_URL_ALT}") \
    && unzip "${DS_INSTALL_DIR}.zip" -d "$TEMP_DIR"

  # Old: mv "${TEMP_DIR}/ds-master" "${DS_INSTALL_DIR}"
  DL_RESULT=$?
  if [ $DL_RESULT -eq 0 ] ; then
    zip_dir=$(unzip -l "${DS_INSTALL_DIR}.zip" | head -5 | tail -1 | awk '{print $NF;}')
    echo "Zip dir: '${zip_dir}'" 1>&2
    mv -f -v "$TEMP_DIR"/"${zip_dir}" "${DS_INSTALL_DIR}" 1>&2
    INST_RESULT=$?
  else
    INST_RESULT=${DL_RESULT}
  fi
fi

# #############################################################################
# Verification

if [ ${INST_RESULT} -ne 0 ] ; then
  echo "${PROGNAME} (ds): FATAL: installation error." 1>&2
  rm -f -r "${DS_INSTALL_DIR}"
  exit ${INST_RESULT}
fi

# #############################################################################
# Cleanup installed plugins list file

# At this point this fresh installation succeeded, so this
#   guarantees there are no status files from previous
#   installations:
eval $(grep DS_PLUGINS_INSTALLED_FILE= "${DS_INSTALL_DIR}/ds.sh")
echo "${PROGNAME} (ds): INFO: Plugins installed file: '${DS_PLUGINS_INSTALLED_FILE}'"
ls -l "${DS_PLUGINS_INSTALLED_FILE}" 2>/dev/null
if [ -f "${DS_PLUGINS_INSTALLED_FILE}" ] ; then
  rm -f -v "${DS_PLUGINS_INSTALLED_FILE}"
fi

# #############################################################################
echo "${PROGNAME} (ds): INFO: Loading Daily Shells and setting shell profiles up..."

. "${DS_INSTALL_DIR}/ds.sh" "${DS_INSTALL_DIR}"

if [ -n "${DS_LOADED}" ] ; then
  touch "${HOME}/.bashrc" "${HOME}/.zshrc"
  appendunique -n "${DS_LOAD_CODE}" "${HOME}/.bashrc" "${HOME}/.zshrc"

  if [ -f "${DS_PLUGINS_FILE:-${HOME}/.dsplugins}" ] ; then
    dshashplugins.sh
  fi
  echo "${PROGNAME} (ds): INFO: DS installed." 1>&2
else
  echo "${PROGNAME} (ds): FATAL: DS installed but could not load it." 1>&2
  exit 99
fi

# #############################################################################
