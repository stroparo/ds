#!/usr/bin/env bash

stashclone () {
  # Syntax: {repo_host} {project_user} {repo_name}
  # Options: [-d targetdir=$PWD/repo_name] [-u stash_user]

  # Examples:
  #  stashclone -u stashuser repohost someproject somereponame

  # Mandatory:
  typeset repo_host project_user repo_name
  typeset repo_proto=https

  # For options:
  typeset stash_user working_repo_dir

  # Derived:
  typeset repo_url_prefix

  # Options:
  OPTIND=1
  while getopts ':d:u:' option ; do
    case "${option}" in
      d) working_repo_dir="${OPTARG}";;
      u) stash_user="${OPTARG}";;
    esac
  done
  shift "$((OPTIND-1))"

  if [ $# -ne 3 ] ; then
    echo "FATAL: Must have 3 args: hostname group|project repo-name" 1>&2
    exit 1
  fi

  repo_host="$1"
  project_user="$2"
  repo_name="$(basename "${3%.git}")"

  if [[ $repo_host = http*://* ]]; then
    if [[ $repo_host = http:* ]]; then
      repo_proto='http'
    fi
    repo_host=${repo_host##*://}
  fi

  repo_url_prefix="${repo_proto}://${stash_user:+${stash_user}@}${repo_host}"
  repo_url_prefix="${repo_url_prefix}/stash/scm"

  : ${working_repo_dir:=$PWD/$repo_name}

  if [ -d "$working_repo_dir" ] ; then
    echo "WARN: Repo already exists, nothing done ($working_repo_dir)" 1>&2
  else
    git clone \
      "${repo_url_prefix}/${project_user}/${repo_name}.git" \
      "${working_repo_dir}"
  fi
}

stashclone "$@"
