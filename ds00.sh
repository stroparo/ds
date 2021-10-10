# Globals

DS_SETUP_URL="https://bitbucket.org/stroparo/ds/raw/master/setup.sh"
DS_SETUP_URL_ALT="https://raw.githubusercontent.com/stroparo/ds/master/setup.sh"

# #############################################################################
# Globals - Mounts prefix root dir filename for Linux and Windows:

if (uname -a | grep -i -q linux) ; then
  MOUNTS_PREFIX="/mnt"
  MOUNTS_PREFIX_EXTERNAL="/media/$USER"
  if egrep -i -q -r 'centos|fedora|oracle|red *hat' /etc/*release ; then
    MOUNTS_PREFIX_EXTERNAL="/var/media/$USER"
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

# Setup the downloader program (curl/wget)
_no_download_program () {
  echo "${PROGNAME} (ds): FATAL: curl and wget missing" 1>&2
  return 1
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
# Globals - the encryption program (truecrypt/veracrypt)

export CRYPTPROG=truecrypt
if ! which "${CRYPTPROG}" >/dev/null 2>&1 && which veracrypt >/dev/null 2>&1 ; then
  export CRYPTPROG=veracrypt
fi

# #############################################################################
# Core functions


# Oneliners
dsh () { dshash -r ; }
dsversion () { echo "==> DRYSL (DRY Scripting Library) - ${DS_VERSION}" ; }


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
    echo "${progname}: INFO: Restoring DRYSL (DRY Scripting Library) backup at '${DS_LAST_BACKUP}'..." 1>&2
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
  # Purpose: rehashing of ds and plugins from local source codebases.
  # Syntax: [-r] [ds-sources-dir:${DEV}/ds]
  #   -r will reload DRYSL (DRY Scripting Library) in the current shell session

  typeset progname="dshash()"

  # Simple option parsing must come first:
  typeset loadcmd=:
  [ "$1" = '-r' ] && loadcmd="echo \"${progname}: INFO: DS loading...\" ; dsload" && shift

  typeset dshome="${DS_HOME:-${HOME}/.ds}"
  typeset dssrc="${1:-${DEV}/ds}"
  typeset errors=false

  # Requirements
  if [ ! -f "${dssrc}/ds.sh" ] ; then
    echo "${progname}: FATAL: No DRYSL (DRY Scripting Library) sources found in '${dssrc}'." 1>&2
    return 1
  fi
  if ! dsbackup ; then
    echo "${progname}: FATAL: error in dsbackup." 1>&2
    return 1
  fi

  echo
  echo "==> DRYSL (DRY Scripting Library) rehash started..."
  rm -f -r "${dshome}" \
    && : > "${DS_PLUGINS_INSTALLED_FILE}" \
    && mkdir "${dshome}" \
    && cp -a "${dssrc}"/* "${dshome}"/ \
    || errors=true

  if ! ${errors:-false} ; then
    echo
    echo "==> DRYSL (DRY Scripting Library) rehash complete"

    echo "${progname}: INFO: Hashing plugins..."
    sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds10path.sh"
    dshashplugins.sh
    sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/ds10path.sh"

    echo "${progname}: INFO: Hashing script modes..."
    chmodscriptsds -v

    eval "$loadcmd"
  else
    echo "${progname}: ERROR: DRYSL (DRY Scripting Library) rehashing failed." 1>&2
    dsrestorebackup
  fi
}


dsupgrade () {

  typeset progname="dsupgrade"

  if [ -z "${DS_HOME}" ] ; then
    echo "${progname}: FATAL: No DS_HOME set." 1>&2
    return 1
  fi
  if [ ! -d "${DS_HOME}" ] ; then
    echo "${progname}: FATAL: No DS_HOME='${DS_HOME}' dir." 1>&2
    return 1
  fi

  if ! dsbackup ; then
    echo "${progname}: FATAL: error in dsbackup." 1>&2
    return 1
  elif (
    rm -rf "${DS_HOME}" \
    && dsload "${DS_HOME}"
  )
  then
    echo "${progname}: SUCCESS: upgrade complete."
    echo "${progname}: INFO: backup at '${DS_LAST_BACKUP}'."
    dsload "${DS_HOME}"
  else
    echo "${progname}: FATAL: upgrade failed." 1>&2
    dsrestorebackup
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
    if [ -e "$dir" ] ; then cd "$dir" ; continue ; fi
    found=$(ls -1d *"${dir}"*/ | head -1)
    if [ -z "$found" ] ; then found="$(find . -type d -name "*${dir}*" | head -1)" ; fi
    if [ -n "$found" ] ; then echo "$found" ; cd "$found" ; fi
  done
  pwd; which exa >/dev/null 2>&1 && exa -ahil || ls -al
  if [ -e ./.git ] ; then
    echo ; git branch -vv
    echo ; git status -s
  fi
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
  bash -c "ls -1 -d '${DS_HOME}/installers'*" 2>/dev/null
  bash -c "ls -1 -d '${DS_HOME}/recipes'*" 2>/dev/null
  bash -c "ls -1 -d '${DS_HOME}/scripts'*" 2>/dev/null
}
dslistscripts () {
  find $(_dsgetscriptsdirs) -type f
}


dshelp () {
  echo "DS - DRYSL (DRY Scripting Library) - Help

d - handy dir navigation function
dshelp - display this help messsage
dsinfo - display environment information
dslistfunctions - list DRYSL (DRY Scripting Library)' functions
dslistscripts - list DRYSL (DRY Scripting Library)' scripts
dsversion - display the version of this DRYSL (DRY Scripting Library) instance
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
  bash -c "$(${DLPROG} ${DLOPT} ${DLOPTEXTRA} ${DLOUT} - "${DS_SETUP_URL}")" setup.sh "${ds_install_dir}"
  if ! . "${DS_HOME}/ds.sh" "${DS_HOME}" 1>&2 || [ -z "${DS_LOADED}" ] ; then
    echo "${progname}: FATAL: Could not load DS - DRYSL (DRY Scripting Library)." 1>&2
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
