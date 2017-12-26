clonefromstash () {
  # Syntax: {repo_host} {project_user} {repo_name}
  # Options: [-d targetdir=$PWD/repo_name] [-u stash_user]

  # Examples:
  #  cloneFromStash -u stashuser repohost someproject somereponame

  # Mandatory:
  typeset repo_host project_user repo_name

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

  if [ $# -ne 2 ] ; then
    echo "FATAL: Must have 2 args namely project user and repo name." 1>&2
  fi

  repo_host="$1"
  project_user="$2"
  repo_name="$(basename "${3%.git}")"

  repo_url_prefix="https://${stash_user:+${stash_user}@}${repo_host}/stash/scm"

  : ${working_repo_dir:=$PWD/$repo_name}

  if [ -d "$working_repo_dir" ] ; then
    echo "WARN: Repo already exists, nothing done ($working_repo_dir)" 1>&2
  else
    git clone \
      "${repo_url_prefix}/${project_user}/${repo_name}.git" \
      "${working_repo_dir}"
  fi
}

