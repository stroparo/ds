#!/usr/bin/env bash

export PROGNAME="stashclone.sh"

stashclone () {
  # Syntax: {repo_host} {owner} {repo_name}
  # Options: [-d targetdir=$PWD/repo_name] [-u stash_user]

  # Examples:
  #  stashclone -u stashuser repohost {owner project/user/group} [repo1 [repo2 [repo3 ...]]]

  # Mandatory:
  typeset repo_host project_user repo_name
  typeset repo_proto=https

  # For options:
  typeset stash_user working_repo_dir

  # Derived:
  typeset repo_url_full repo_url_prefix
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
  project_user="$1"; shift

  if [ -n "$working_repo_dir" ] && [ $# -gt 2 ] ; then
    echo "${PROGNAME:+$PROGNAME: }FATAL: Cannot set a repo dir having more than one repo to be cloned." 1>&2
    exit 1
  fi

  for repo_name in "$@" ; do

    repo_name="$(basename "${repo_name%.git}")"

    echo ${BASH_VERSION:+-e} "\n==> Repo '$repo_name'..."

    if [[ $repo_host = http*://* ]]; then
      if [[ $repo_host = http:* ]]; then
        repo_proto='http'
      fi
      repo_host=${repo_host##*://}
    fi

    repo_url_prefix="${repo_proto}://${stash_user:+${stash_user}@}${repo_host}"
    repo_url_prefix="${repo_url_prefix}/stash/scm"
    repo_url_full="${repo_url_prefix}/${project_user}/${repo_name}.git"

    echo "    URL: '${repo_url_full}'"
    git clone --depth=1 "${repo_url_full}"
  done

  if [ -n "$working_repo_dir" ] && [ $# -gt 2 ] ; then
    repo_basename="${working_repo_dir##*/}"
    repo_basename="${working_repo_dir%.git}"
    mv "$repo_basename" "$working_repo_dir"
  fi
}

stashclone "$@" || exit $?
