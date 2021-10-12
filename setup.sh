#!/usr/bin/env bash

# Scripting Library setup / installation routine

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

# Default INSTALL_DIR to not evaluate some variable if passed
# in the directory, so it goes in the "load code" variable
# which will be appended to the shell profiles as is:
DS_INSTALL_DIR="$(echo "${1:-\${HOME\}/.ds}" | tr -s /)"
DS_LOAD_CODE="[ -r \"${DS_INSTALL_DIR}/ds.sh\" ] && source \"${DS_INSTALL_DIR}/ds.sh\" \"${DS_INSTALL_DIR}\" 1>&2"

# After having that "load code" for shell profiles,
#   finally eval the installation dir to proceed:
DS_INSTALL_DIR="$(eval echo "\"${DS_INSTALL_DIR}\"")"

BACKUP_FILENAME="${DS_INSTALL_DIR}-$(date '+%y%m%d-%OH%OM%OS')"

# Setup the downloader program (curl/wget)
_no_download_program () {
  echo "${PROGNAME} (ds): FATAL: curl and wget missing" 1>&2
  exit 1
}
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
  export DLPROG=_no_download_program
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
  echo "DRYSL - DRY Scripting Library setup from local dir '${PWD}'..." 1>&2
  mkdir "${DS_INSTALL_DIR}" \
    && cp -f -R -v "${PWD}"/* "${DS_INSTALL_DIR}"/
  INST_RESULT=$?
  echo "${PROGNAME} (ds): INFO: DRYSL - DRY Scripting Library setup dir used was '${PWD}'"
else
  echo "DRYSL - DRY Scripting Library setup: downloading and installing..." 1>&2
  ("${DLPROG}" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${DS_INSTALL_DIR}.zip" "${DS_PKG_URL}" \
    || "${DLPROG}" ${DLOPT} ${DLOPTEXTRA} ${DLOUT} "${DS_INSTALL_DIR}.zip" "${DS_PKG_URL_ALT}") \
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
rm -f -v "${DS_PLUGINS_INSTALLED_FILE}" 2>/dev/null

# #############################################################################
echo "${PROGNAME} (ds): INFO: Loading DRYSL - DRY Scripting Library..."

. "${DS_INSTALL_DIR}/ds.sh" "${DS_INSTALL_DIR}"

if [ -n "${DS_LOADED}" ] ; then
  echo "${PROGNAME} (ds): INFO: Setting shell profiles up..."
  touch "${HOME}/.bashrc" "${HOME}/.zshrc"
  # About greps below,
  #   omitting the path in the pattern (/ds.sh) is on purpose since
  #   DS could have been installed with a non evaluated variable
  #   in the profiles earlier, and a reinstallation client code
  #   calling this might have passed in an actual path, which
  #   would cause appendunique to not be unique anymore thus
  #   putting in another ie duplicate DS loading code:
  if ! grep -q "/ds.sh" "${HOME}/.bashrc" ; then
    appendunique -n "${DS_LOAD_CODE}" "${HOME}/.bashrc"
  fi
  if ! grep -q "/ds.sh" "${HOME}/.zshrc" ; then
    appendunique -n "${DS_LOAD_CODE}" "${HOME}/.zshrc"
  fi

  echo "${PROGNAME} (ds): INFO: Hashing plugins..."
  dshashplugins.sh

  echo "${PROGNAME} (ds): INFO: Hashing script modes..."
  chmodscriptsds -v

  echo "${PROGNAME} (ds): INFO: DS installed." 1>&2

  exit 0
else
  echo "${PROGNAME} (ds): FATAL: DS installed but could not load it." 1>&2

  exit 99
fi

# #############################################################################
