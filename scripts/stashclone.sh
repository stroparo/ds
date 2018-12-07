#!/usr/bin/env bash

export PROGNAME="stashclone.sh"

stashclone () {
  # Syntax: {repo_host} {owner} {repo_name}
  # Options: [-d targetdir=$PWD/repo_name] [-u stash_user]

  # Examples:
  #  stashclone -u stashuser repohost {owner project/user/group} [repo1 [repo2 [repo3 ...]]]

  # Mandatory:
  typeset repo_host project_owner repo_name
  typeset repo_host_proto="https"

  # For options:
  typeset stash_user working_repo_dir

  # Derived:
  typeset repo_url
  typeset repo_basename

  # Options:
  OPTIND=1
  while getopts ':d:u:' option ; do
    case "${option}" in
      d) working_repo_dir="${OPTARG}";;
      u) stash_user="${OPTARG}";;
    esac
  done
  shift "$((OPTIND-1))"

  if [ $# -lt 3 ] ; then
    echo "FATAL: Must have at least 3 args: hostname {group|project|user} [repos...]" 1>&2
    exit 1
  fi

  repo_host="$1"; shift
  project_owner="$1"; shift

  if [ -n "$working_repo_dir" ] && [ $# -gt 2 ] ; then
    echo "${PROGNAME:+$PROGNAME: }FATAL: Cannot set a repo dir having more than one repo to be cloned." 1>&2
    exit 1
  fi

  for repo_name in "$@" ; do
    # If the repo_name is a URL use that and ignore other args such as host, otherwise assemble the URL:
    if [[ $repo_name = http*// ]] || [[ $repo_name = ssh*// ]] ; then
      repo_url="${repo_name}"
      if ! [[ $repo_name = *@* ]] ; then
        repo_url="$(echo "${repo_url}" | sed -e "s#^[^:]*://#&${stash_user}@#")"
      fi
    else
      repo_name="$(basename "${repo_name%.git}")"
      repo_host_proto="${repo_host%%://*}"
      repo_url="${stash_user:+${stash_user}@}${repo_host##*://}"
      repo_url="${repo_host_proto:-https}://${repo_url}/stash/scm/${project_owner}/${repo_name}.git"
    fi

    echo ${BASH_VERSION:+-e} "\n==> Repo '$repo_name'..."
    echo "    URL: '${repo_url}'"
    git clone "${repo_url}"
  done

  if [ -n "$working_repo_dir" ] && [ $# -gt 2 ] ; then
    repo_basename="${working_repo_dir##*/}"
    repo_basename="${working_repo_dir%.git}"
    mv "$repo_basename" "$working_repo_dir"
  fi
}

stashclone "$@" || exit $?
