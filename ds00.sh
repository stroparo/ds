# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

alias cdbak='d "${DS_ENV_BAK}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias t='d "${TEMP_DIRECTORY}" -A'

dsinfo () { dsversion ; echo "DS_HOME='${DS_HOME}'" 1>&2 ; }
dsversion () { echo "Daily Shells - ${DS_VERSION}" 1>&2 ; }

unalias d 2>/dev/null
unset d 2>/dev/null
d () {
  dir="${1}"
  shift
  cd "${dir}" || return 1
  pwd 1>&2
  ls -Fl "$@" 1>&2
  if [ -e ./.git ] ; then
    git branch -avv
  fi
}

dsbackup () {
  typeset dshome="${1:-${DS_HOME:-${HOME}/.ds}}"
  typeset timestamp="$(date +%Y%m%d-%OH%OM%OS)"

  cp -a "$dshome" "$dshome-$timestamp" \
    && echo "$dshome-$timestamp"
}

dsf () {

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
    findscripts.sh "root"
  done
}

dshelp () {
  echo "DS - Daily Shells Library - Help

dsf - list daily shells' functions
dss - list daily shells' scripts
dshelp - display this help messsage
dsinfo - display environment information
dsversion - display the version of this Daily Shells instance
" 1>&2
}

dsload () {
  # Info: loads ds. If it does not exist, download and install to the default path.
  # Syn: [dshome=~/.ds]

  typeset dshome="${1:-${DS_HOME:-${HOME}/.ds}}"

  if [ -f "${dshome}/ds.sh" ] ; then
    . "${dshome}/ds.sh" "$ds_home"
  else
    echo "INFO: Installing DS into '${dshome}' ..." 1>&2
    export DS_HOME="$dshome"
    bash -c "$(wget -O - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')" \
      && . "${dshome}/ds.sh" "${dshome}" 1>&2
    if [ $? -ne 0 ] || [ -z "${DS_LOADED}" ] ; then
      echo "FATAL: Could not load DS - Daily Shells." 1>&2
      return 1
    else
      return 0
    fi
  fi
}

dsupgrade () {
  typeset backup=$(dsbackup)

  if [ -z "$backup" ] ; then
    echo "FATAL: backup failed... sequence cancelled" 1>&2
    return 1
  fi

  if [ -n "$backup" ] && rm -rf "$DS_HOME" && dsload "$DS_HOME" ; then
    echo "SUCCESS: upgrade complete (beware of any backups left at DS_HOME-{timestamp})"
  else
    echo "FATAL: upgrade failed ... restoring '${backup}' ..." 1>&2
    rm -f -r "$DS_HOME" \
      && mv -f "$backup" "$DS_HOME" \
      && echo "SUCCESS: restored '${backup}' into '${DS_HOME}'"
    if [ $? -ne 0 ] ; then
      echo "FATAL: restore failed" 1>&2
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

# #############################################################################
# Testing routines

_is_interactive () { [[ "$-" = *i* ]] ; }

_all_dirs_r () {
  for i in "$@" ; do [ ! -d "${1}" -o ! -r "${1}" ] && return 1 ; done ; return 0
}
_all_dirs_rwx () {
  # Tests if any of the directory arguments are neither readable nor w nor x.
  for i in "$@" ; do
    if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
      return 1
    fi
  done
  return 0
}
_all_dirs_w () {
  for i in "$@" ; do [ ! -d "${1}" -o ! -w "${1}" ] && return 1 ; done ; return 0
}
_all_exist () {
  for i in "$@" ; do [ ! -e "${1}" ] && return 1 ; done ; return 0
}
_all_not_null () {
  for i in "$@" ; do [ -z "${i}" ] && return 1 ; done ; return 0
}
_all_r () {
  for i in "$@" ; do [ ! -r "${1}" ] && return 1 ; done ; return 0
}
_all_w () {
  for i in "$@" ; do [ ! -w "${1}" ] && return 1 ; done ; return 0
}
_any_dir_not_r () {
  ! _all_dirs_r "$@"
}
_any_dir_not_rwx () {
  ! _all_dirs_rwx "$@"
}
_any_dir_not_w () {
  ! _all_dirs_w "$@"
}
_any_exists () {
  for i in "$@" ; do [ -e "${1}" ] && return 0 ; done ; return 1
}
_any_not_exists () {
  ! _all_exist "$@"
}
_any_not_r () {
  ! _all_r "$@"
}
_any_not_w () {
  ! _all_w "$@"
}
_any_null () {
  for i in "$@" ; do [ -z "${i}" ] && return 0 ; done ; return 1
}

_has_gnu () {
  find --version 2> /dev/null | grep -i -q 'gnu'
}
