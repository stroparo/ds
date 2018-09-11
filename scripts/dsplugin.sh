#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# Plugin installer for Daily Shells

ckds () {
  if [ -z "${DS_VERSION}" ] && ! . "${DS_HOME}/ds.sh" "${DS_HOME}" >/dev/null 2>&1
  then
    echo "No DS Daily Shells loaded. Fix it and call this again." 1>&2
    echo "Tips:" 1>&2
    echo "curl -o - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh' | bash" 1>&2
    echo "wget -O - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh' | bash" 1>&2
    return 1
  fi
}
ckds || exit $?

! which git >/dev/null && echo "FATAL: git not in path" 1>&2 && exit 1

# #############################################################################
# Globals

export WORKDIR="$HOME"

export PNAME="$(basename "$0")"

export USAGE="
NAME
  ${PNAME} - Installs Daily Shells plugins

SYNOPSIS
  ${PNAME} [domain/]user/repo [[d/]u/r [[d/]u/r ...]]
  -s option will make it SSH (git@domain:user/repo)

DESCRIPTION
  Clone the repository pointed to by the argument.
  If no domain given, github.com will be the default.
"

# #############################################################################
# Prep args

# Options:

export DOMAIN=github.com
export QUIET=false
export USE_SSH=false
export VERBOSE=false

OPTIND=1
while getopts ':hqsv' opt ; do
  case ${opt} in

    h) echo "${USAGE}" ; exit ;;

    q) export QUIET=true;;
    s) export USE_SSH=true;;
    v) export VERBOSE=true;;

  esac
done
shift $((OPTIND - 1))

if [ $# -eq 0 ] ; then
  echo "$USAGE"
  exit 1
fi

# #############################################################################
# Functions

main () {

  typeset domain user repo remainder # for repo URLs
  typeset protocol
  typeset repo_dir
  typeset repo_url

  for plugin in "$@" ; do

    protocol=$(echo "$plugin" | grep -o "^.*://")
    protocol=${protocol%://}
    : ${protocol:=https}
    original_plugin_string="${plugin}"
    plugin="${plugin#*://}"

    [ -z "$plugin" ] && echo "WARN: empty arg ignored" && continue

    IFS='/' read domain user repo remainder <<EOF
${plugin}
EOF

    if [ -z "$domain" ] ; then
      echo "FATAL: Must pass at least [user/]repo." 1>&2
      echo 1>&2
      echo "$USAGE" 1>&2
      exit 1
    elif [ -z "$user" ] ; then
      echo "WARN: No 'domain/{user}/' prefix, defaulting to 'github.com/stroparo/'..." 1>&2
      # Shift right and put in a default domain and user:
      repo=$domain
      user=stroparo
      domain=github.com
    elif [ -z "$repo" ] ; then
      echo "WARN: No domain, defaulting to 'github.com'..." 1>&2
      # Shift right and put in a default domain:
      repo=$user
      user=$domain
      domain=github.com
    fi

    # Support longer URLs (more than one dir after the user):
    if [ -n "$remainder" ] ; then
      repo="${repo}/${remainder}"
    fi

    repo_dir=$(basename "${repo%.git}")
    if ${USE_SSH:-false} ; then
      repo_url="git@$domain/$user/${repo%.git}.git"
    else
      repo_url="${protocol}://$domain/$user/${repo%.git}.git"
    fi

    echo "==> Cloning '$repo_url'..."

    git clone --depth 1 "$repo_url" \
      && rm -f -r "${repo_dit}/.git" \
      && cp -a "${repo_dir}"/* "${DS_HOME}/" \
      && (grep -q "^${original_plugin_string}\$" "${HOME}/.dsplugins" \
            || echo "${original_plugin_string}" >> "${HOME}/.dsplugins") \
      && rm -f -r "${repo_dir}" \
      && echo \
      && echo "INFO: Plugin at '${repo_url}' installed successfully" \
      && echo

    if [ $? -ne 0 ] ; then
      echo "WARN: There was some error for '${plugin}'." 1>&2
      rm -f -r "${repo}"
    fi

    # Safety for next iteration:
    unset domain repo repo_url user
  done

}

# #############################################################################
# Main

cd "$WORKDIR"
if [ "${PWD%/}" != "${WORKDIR%/}" ] ; then
  echo "FATAL: Could not cd to '${WORKDIR%/}'." 1>&2
  exit 1
fi

main "$@"
exit "$?"
