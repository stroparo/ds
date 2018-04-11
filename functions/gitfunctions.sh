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
        echo "FATAL: Cloning '$repo' repository to '${repo_path}/'." 1>&2
        return 1
      fi
    else
      echo "SKIP: '$repo_path' repository already exists." 1>&2
    fi

    echo '' 1>&2
  done <<EOF
${1}
EOF
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
    $verbose && echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where user.email "$email"
    $verbose && echo '---'
  fi

  if [ -n "$name" ]  ; then
    $verbose && echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where user.name "$name"
    $verbose && echo '---'
  fi

  while [ $# -ge 2 ] ; do
    $verbose && echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where "$1" "$2"
    $verbose && echo '---'
    shift 2
  done
}
