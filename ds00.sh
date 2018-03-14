# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Globals

SETUP_URL='https://raw.githubusercontent.com/stroparo/ds/master/setup.sh'

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

# Aliases
alias cdbak='d "${DS_ENV_BAK}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias t='d "${TEMP_DIRECTORY}" -A'

# Oneliners
dsversion () { echo "==> Daily Shells - ${DS_VERSION}" ; }

unalias d 2>/dev/null
unset d 2>/dev/null
d () {
  if [ -e "$dir" ] ; then
    cd "$dir"
  else
    for dir in "$@" ; do
      found="$(find . -type d -name "*${dir}*" | head -1)"
      if [ -n "$found" ] ; then cd "${found}" && pwd 1>&2 ; fi
    done
  fi
  if [ -e ./.git ] ; then git branch -vv ; fi
}

dsbackup () {
  typeset dshome="${1:-${DS_HOME:-${HOME}/.ds}}"
  typeset timestamp="$(date +%Y%m%d-%OH%OM%OS)"

  cp -a "$dshome" "$dshome-$timestamp" \
    && echo "$dshome-$timestamp"
}

dsgetfunctions () {

  typeset filename item items itemslength

  for i in $(ls -1 "$DS_HOME"/functions/*sh) ; do

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

dsgetscripts () {
  typeset ignore_expr='/(conf|functions|templates)'
  typeset roots="$(ls -1 -d "${DS_HOME}"/scripts/*/ \
    | grep -v "${ignore_expr}")"

  for root in "$roots" ; do
    findscripts.sh "$root"
  done
}

dshelp () {
  echo "DS - Daily Shells Library - Help

dsgetfunctions - list daily shells' functions
dsgetscripts - list daily shells' scripts
dshelp - display this help messsage
dsinfo - display environment information
dsversion - display the version of this Daily Shells instance
" 1>&2
}

dsinfo () {
  dsversion 1>&2
  echo "DS_HOME='${DS_HOME}'" 1>&2
}

dsload () {
  # Info: loads ds. If it does not exist, download and install to the default path.
  # Syn: [dshome=~/.ds]

  typeset dshome="${1:-${DS_HOME:-${HOME}/.ds}}"

  if [ -f "${dshome}/ds.sh" ] ; then
    . "${dshome}/ds.sh" "$ds_home"
    return $?
  fi

  export DS_HOME="$dshome"

  echo "INFO: Installing DS into '${dshome}' ..." 1>&2
  bash -c "$($DLPROG $DLOPT $DLOUT - "$SETUP_URL")" dummy "$dshome" \
    && . "${dshome}/ds.sh" "${dshome}" 1>&2

  if [ $? -ne 0 ] || [ -z "${DS_LOADED}" ] ; then
    echo "FATAL: Could not load DS - Daily Shells." 1>&2
    return 1
  else
    return 0
  fi
}

dsupgrade () {
  typeset backup

  if [ -z "$DS_HOME" ] ; then
    echo "dsupgrade: FATAL: No DS_HOME set." 1>&2
    return 1
  fi

  backup=$(dsbackup)

  if [ -z "$backup" ] ; then
    echo "dsupgrade: FATAL: backup failed... sequence cancelled" 1>&2
    return 1
  elif rm -rf "$DS_HOME" && dsload "$DS_HOME" ; then
    echo "dsupgrade: SUCCESS: upgrade complete (beware of any backups left at $DS_HOME-{some timestamp})"
  else
    echo "dsupgrade: FATAL: upgrade failed ... restoring '${backup}' ..." 1>&2
    rm -f -r "$DS_HOME" \
      && mv -f "$backup" "$DS_HOME" \
      && echo "dsupgrade: SUCCESS: restored '${backup}' into '${DS_HOME}'"
    if [ $? -ne 0 ] ; then
      echo "dsupgrade: FATAL: restore failed" 1>&2
      return 1
    fi
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
