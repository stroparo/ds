# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# Git routines
# #############################################################################


clonegits () {
  # Info: Clone repos passed in the argument, one per line (quote it).
  # Syntax: {repositories-one-per-line}

  [ -z "${1}" ] && return

  while read repo repo_path ; do
    [ -z "${repo}" ] && continue
    [ -z "${repo_path}" ] && repo_path="$(basename "${repo%.git}")"

    if [ ! -d "$repo_path" ] ; then
      if ! git clone "$repo" "$repo_path" ; then
        echo "clonegits: ERROR: Cloning '$repo' repository to '${repo_path}/'." 1>&2
      fi
    else
      echo "clonegits: SKIP: '$repo_path' repository already exists." 1>&2
    fi

    echo '' 1>&2
  done <<EOF
${1}
EOF
}


clonemygits () {
  typeset devdir="${DEV:-$HOME/workspace}"
  typeset mygits

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':d:' option ; do
    case "${option}" in
      d) devdir="${OPTARG}";;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$1" ] ; then
    mygits="$*"
  else
    mygits="$MYGITS"
  fi
  if [ -z "$mygits" ] ; then
    echo "clonemygits: SKIP: no Git repos in MYGITS or args." 1>&2
    return
  fi

  if [ -d "${devdir}" ] ; then
    # Using the clonegits function from Daily Shells at stroparo.github.io/ds:
    (cd "${devdir}" \
      && [ "$(basename "$(pwd)")" = "$(basename "$devdir")" ] \
      && clonegits "$mygits")
  fi
}


confgits () {
  for repo in "$@" ; do
    [ -d "$repo/.git" ] || continue
    touch "$repo/.git/config"
    gitset -e "$MYEMAIL" -n "$MYSIGN" -r -v -f "$repo/.git/config"
  done
}


gitenforcemyuser () {
  [ -n "$MYEMAIL" ] && git config --global --replace-all user.email "$MYEMAIL"
  [ -n "$MYSIGN" ] && git config --global --replace-all user.name "$MYSIGN"
}


gitremotepatternreplace () {
  # Usage: {sed-pattern} {replacement} [repo paths]

  typeset branch_name=origin
  typeset post_replace_sync=false

  typeset pattern
  typeset replace

  # Options:
  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':b:s' option ; do
    case "${option}" in
      b) branch_name="${OPTARG}";;
      s) post_replace_sync=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  pattern="$1"
  replace="$2"
  shift 2

  for repo in "$@" ; do
    echo "==> Repo: '$repo'"
    (
      cd $repo
      old_remote_value="$(git remote -v | grep $branch_name | head -1 | awk '{print $2;}')"
      new_remote_value="$(echo "$old_remote_value" | sed -e "s#${pattern}#${replace}#")"
      echo "Old '$branch_name' branch: $old_remote_value"
      echo "New '$branch_name' branch: $new_remote_value"
      git remote remove $branch_name
      git remote add $branch_name "$new_remote_value"
      if "${post_replace_sync:-false}" ; then
        git pull $branch_name
        git push $branch_name HEAD
      fi
    )
  done
}


gitset () {
  # Info: Configure git.
  # Syn: [-e email] [-n name] [-f file] [-r]
  # Example: gitset "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'

  typeset email name replace where
  typeset verbose=false

  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':e:f:n:rv' opt ; do
    case "${opt}" in
    e) email="${OPTARG}" ;;
    f) where="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    r) replace="--replace-all";;
    v) verbose=true;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$where" ]; then
    if [ ! -w "${where}" ] ; then
      echo "FATAL: Must pass writeable file to -f option." 1>&2
      return 1
    else
      where="-f${where}"
    fi
  else
    where='--global'
  fi

  if [ -n "$email" ] ; then
    $verbose && echo "==>" git config $replace $where "user.email" "$email" 1>&2
    git config $replace $where user.email "$email"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  if [ -n "$name" ]  ; then
    $verbose && echo "==>" git config $replace $where "user.name" "$name" 1>&2
    git config $replace $where user.name "$name"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
  fi

  while [ $# -ge 2 ] ; do
    $verbose && echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where "$1" "$2"
    $verbose && echo "\$?=$?"
    $verbose && echo '---'
    shift 2
  done
}


gpa () {
  # Info: Git push all
  # Syn: [branch=master]

  typeset branch="${1:-master}"
  typeset remote

  git checkout master
  for remote in $(git remote) ; do
    echo "gpa: INFO: Pushing to '${remote}' remote.."
    git push $remote master
  done
}

