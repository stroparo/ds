# DS - Daily Shells Library

# #############################################################################
# Globals

DS_SETUP_URL="https://bitbucket.org/stroparo/ds/raw/master/setup.sh"
DS_SETUP_URL_ALT="https://raw.githubusercontent.com/stroparo/ds/master/setup.sh"

# #############################################################################
# Globals - Mounts prefix root dir filename for Linux and Windows:

if (uname -a | grep -i -q linux) ; then
  MOUNTS_PREFIX="/media/$USER"
  if egrep -i -q -r 'centos|fedora|oracle|red *hat' /etc/*release ; then
    MOUNTS_PREFIX="/var/media/$USER"
  fi
elif (uname -a | egrep -i -q "cygwin|mingw|msys|win32|windows") ; then
  if [ -d '/c/Windows' ] ; then
    MOUNTS_PREFIX=""
  elif [ -d '/drives/c/Windows' ] ; then
    MOUNTS_PREFIX="/drives"
  elif [ -d '/cygdrive/c/Windows' ] ; then
    MOUNTS_PREFIX="/cygdrive"
  fi
fi

# #############################################################################
# Globals - the downloader program (curl/wget)

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
# Aliases

alias cdbak='d "${DS_ENV_BAK}"'
alias cde='d "${DS_ENV}"'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='cd "${DS_ENV_LOG}" && ls -AFlrt'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias t='d "${TEMP_DIRECTORY}"'

# #############################################################################
# Oneliners

dsversion () { echo "==> Daily Shells - ${DS_VERSION}" ; }

# #############################################################################
# Provisioning functions


dsbackup () {
  typeset dshome="${1:-${DS_HOME:-${HOME}/.ds}}"
  typeset timestamp="$(date +%Y%m%d-%OH%OM%OS)"
  typeset bakdir="${DS_BACKUPS_DIR}/${timestamp}"

  [ -d "${bakdir}" ] || mkdir -p "${bakdir}"
  ls -d "${bakdir}" >/dev/null || return $?

  export DS_LAST_BACKUP=""
  ls -1 -d "${dshome}"/* >/dev/null 2>&1 || return 0
  cp -a "${dshome}"/* "${bakdir}"/
  if [ $? -eq 0 ] ; then
    export DS_LAST_BACKUP="$(ls -1 -d "${bakdir}")"
    echo "${DS_LAST_BACKUP}"
    return 0
  else
    return 1
  fi
}


dsrestorebackup () {
  typeset progname="dsrestorebackup"
  DS_LAST_BACKUP="${DS_LAST_BACKUP:-${DS_BACKUPS_DIR}/${1##$DS_BACKUPS_DIR/}}"

  if [ -z "${DS_LAST_BACKUP}" ] ; then
    echo "${progname}: SKIP: No last backup in the current session." 1>&2
    return 1
  fi

  if [ -d "${DS_LAST_BACKUP}" ] ; then
    echo "${progname}: INFO: Restoring Daily Shells backup..." 1>&2
    rm -f -r "${DS_HOME}";  mkdir "${DS_HOME}"
    if [ -d "${DS_HOME}" ] \
      && [ ! -f "${DS_HOME}/ds.sh" ] \
      && cp -a -v "${DS_LAST_BACKUP}/"* "${DS_HOME}/"
    then
      echo "${progname}: INFO: Backup restored" 1>&2
      return 0
    else
      echo "${progname}: FATAL: Restore failed" 1>&2
      return 1
    fi
  else
    echo "${progname}: FATAL: There was no previous DS version backed up" 1>&2
    return 1
  fi
}


dshash () {
  # Syntax: [-r] [ds-sources-dir:${DEV}/ds]

  typeset progname="dshash"

  # Simple option parsing must come first:
  typeset loadcmd=:
  [ "$1" = '-r' ] && loadcmd="echo \"${progname}: INFO: DS loading...\" ; dsload" && shift

  typeset dshome="${DS_HOME:-${HOME}/.ds}"
  typeset dssrc="${1:-${DEV}/ds}"
  typeset errors=false

  # Requirements
  if [ ! -f "${dssrc}/ds.sh" ] ; then
    echo "${progname}: FATAL: No Daily Shells sources found in '${dssrc}'." 1>&2
    return 1
  fi
  dsbackup_dir="$(dsbackup)"; dsbackup_res=$?
  if [ "${dsbackup_res:-1}" -ne 0 ] || [ ! -d "${dsbackup_dir}" ] ; then
    echo "${progname}: FATAL: error in dsbackup." 1>&2
    return 1
  fi

  echo
  echo "==> Daily Shells rehash started..."
  rm -f -r "${dshome}" \
    && : > "${DS_PLUGINS_INSTALLED_FILE}" \
    && mkdir "${dshome}" \
    && cp -a "${dssrc}"/* "${dshome}"/ \
    || errors=true

  if ! ${errors:-false} ; then
    echo
    echo "==> Daily Shells rehash complete"
    sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds10path.sh"
    dshashplugins.sh
    eval "$loadcmd"
  else
    echo "${progname}: ERROR: Daily Shells rehash failure" 1>&2
    dsrestorebackup
    return 0
  fi
}


dsupgrade () {
  typeset backup
  typeset progname="dsupgrade"

  if [ -z "${DS_HOME}" ] ; then
    echo "${progname}: FATAL: No DS_HOME set." 1>&2
    return 1
  fi
  if [ ! -d "${DS_HOME}" ] ; then
    echo "${progname}: FATAL: No DS_HOME='${DS_HOME}' dir." 1>&2
    return 1
  fi

  backup="$(dsbackup)"

  if [ $? -ne 0 ] || [ -z "${backup}" ] || [ ! -f "${backup}/ds.sh" ]; then
    echo "${progname}: FATAL: backup failed... sequence cancelled" 1>&2
    return 1
  elif (
    rm -rf "${DS_HOME}" \
    && dsload "${DS_HOME}"
  )
  then
    echo "${progname}: SUCCESS: upgrade complete - backup of previous version at '${backup}'"
    dsload "${DS_HOME}"
  else
    echo "${progname}: FATAL: upgrade failed ... restoring '${backup}' ..." 1>&2
    rm -f -r "${DS_HOME}" \
      && cp -a -f "${backup}" "${DS_HOME}" \
      && echo "${progname}: SUCCESS: restored '${backup}' into '${DS_HOME}'"
    if [ $? -ne 0 ] ; then
      echo "${progname}: FATAL: restore failed" 1>&2
      return 1
    fi
  fi
}


# #############################################################################
# Functions


# Function d - Dir navigation
unalias d 2>/dev/null
unset d 2>/dev/null
d () {
  if [ -e "$1" ] ; then cd "$1" ; shift ; fi
  for dir in "$@" ; do
    found=$(ls -1d *"${dir}"*/ | head -1)
    if [ -z "$found" ] ; then found="$(find . -type d -name "*${dir}*" | head -1)" ; fi
    if [ -n "$found" ] ; then echo "$found" ; cd "$found" ; fi
  done
  pwd; which exa >/dev/null 2>&1 && exa -ahil || ls -al
  if [ -e ./.git ] ; then git branch -vv ; fi
}


dslistfunctions () {

  typeset filename item items itemslength

  for i in $(ls -1 "${DS_HOME}"/functions/*sh) ; do

    items=$(egrep '^ *(function [_a-zA-Z0-9][_a-zA-Z0-9]* *[{]|[_a-zA-Z0-9][_a-zA-Z0-9]* *[(][)] *[{])' "$i" /dev/null | \
          sed -e 's#^.*functions/##' -e  's/[(][)].*$//')
    filename=$(echo "$items" | head -n 1 | cut -d: -f1)
    items=$(echo "$items" | cut -d: -f2)
    itemslength=$(echo "$items" | wc -l | awk '{print $1;}')

    if [ -n "$items" ] ; then
      for item in $(echo "$items" | cut -d: -f2) ; do
        echo "$item in $filename"
      done
    fi
  done | sort
}


_dsgetscriptsdirs () {
  typeset ignore_expr="${DS_HOME}/(conf|functions|templates)"
  ls -1 -d "${DS_HOME}"/*/ \
    | grep -E -v "${ignore_expr}" \
    | sed -e 's#//*$##'
}
dslistscripts () {
  for dir in $(_dsgetscriptsdirs) ; do
    findscripts.sh "$dir"
  done
}


# Handy dshash wrappers
dsh () { dshash -r ; }
dshfull () { (v ; rpull ; dshash) ; dsload ; }


dshelp () {
  echo "DS - Daily Shells Library - Help

dshelp - display this help messsage
dsinfo - display environment information
dslistfunctions - list daily shells' functions
dslistscripts - list daily shells' scripts
dsversion - display the version of this Daily Shells instance
" 1>&2
}


dsinfo () {
  dsversion 1>&2
  echo "DS_HOME='${DS_HOME}'" 1>&2
}


dsload () {
  typeset progname="dsload"

  # Info: loads ds. If it does not exist, download and install to the default path.
  # Syn: [ds_home=~/.ds]

  typeset ds_install_dir="$(echo "${1:-${DS_HOME:-\${HOME\}/.ds}}" | tr -s /)"
  typeset ds_home="$(eval echo "\"${ds_install_dir}\"")"

  if [ -f "${ds_home}/ds.sh" ] ; then
    . "${ds_home}/ds.sh" "$ds_home"
    return $?
  fi

  export DS_HOME="${ds_home}"
  echo
  echo "${progname}: INFO: Installing DS into '${ds_install_dir}' ('${DS_HOME}') ..." 1>&2
  unset DS_LOADED
  bash -c "$(${DLPROG} ${DLOPT} ${DLOUT} - "${DS_SETUP_URL}")" setup.sh "${ds_install_dir}"
  if ! . "${DS_HOME}/ds.sh" "${DS_HOME}" 1>&2 || [ -z "${DS_LOADED}" ] ; then
    echo "${progname}: FATAL: Could not load DS - Daily Shells." 1>&2
    return 1
  else
    return 0
  fi
}


sourcefiles () {
  # Info: Each arg is a glob; source all glob expanded paths.
  #  Tilde paths are accepted, as the expansion is yielded
  #  via eval. Expanded directories are ignored.
  #  Stdout is fully redirected to stderr.

  typeset pname='sourcefiles'
  typeset quiet=false
  typeset tolerant=false
  typeset verbose=false

  typeset name src srcs srcresult
  typeset nta='Non-tolerant abort.'

  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':n:qtv' opt ; do
    case "${opt}" in
      n) name="${OPTARG}";;
      q) quiet=true;;
      t) tolerant=true;;
      v) verbose=true;;
    esac
  done
  shift $((OPTIND - 1)) ; OPTIND="${oldind}"

  if test -n "${name}" && $verbose && ! $quiet ; then
    echo "==> Sourcing group '${name}'" 1>&2
  fi

  for globpattern in "$@" ; do

    srcs="$(eval command ls -1d ${globpattern} 2>/dev/null)"

    if [ -z "$srcs" ] ; then
      if ! ${tolerant} ; then
        $quiet || echo "FATAL: $nta Bad glob." 1>&2
        return 1
      fi
      continue
    fi

    exec 4<&0

    while read src ; do

      $verbose && ! $quiet && echo "==> Sourcing '${src}' ..." 1>&2

      if [ -r "${src}" ] ; then
        . "${src}" 1>&2
      else
        $quiet || echo "$warn '${src}' is not readable." 1>&2
        false
      fi
      srcresult=$?

      if [ "${srcresult}" -ne 0 ] ; then
        if ! $tolerant ; then
          $quiet || echo "FATAL: ${nta} While sourcing '${src}'." 1>&2
          return 1
        fi

        $quiet || echo "WARN: Tolerant fail for '${src}'." 1>&2
      # else
      #     if $verbose && ! $quiet ; then
      #         echo "INFO: => '${src}' completed successfully." 1>&2
      #     fi
      fi
    done <<EOF
${srcs}
EOF
  done
  if $verbose && test -n "${name}" ; then
    echo "INFO: group '${name}' sourcing complete." 1>&2
  fi
}
