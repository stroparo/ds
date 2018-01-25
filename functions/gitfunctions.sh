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

  while read repo ; do
    [ -z "${repo}" ] && continue

    if [ ! -d "$(basename "${repo%.git}")" ] ; then
      if ! git clone "${repo}" ; then
        echo "FATAL: Cloning '${repo}' repository." 1>&2
        return 1
      fi
    else
      echo "SKIP: '$(basename "${repo%.git}")' repository already exists." 1>&2
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

  typeset oldind="${OPTIND}"
  OPTIND=1
  while getopts ':e:f:n:r' opt ; do
    case "${opt}" in
    e) email="${OPTARG}" ;;
    f) where="${OPTARG}" ;;
    n) name="${OPTARG}" ;;
    r) replace="--replace-all";;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND="${oldind}"

  if [ -n "$where" ]; then
    if _any_not_w "${where}" ; then
      echo "FATAL: Must pass writeable file to -f option." 1>&2
      return 1
    else
      where="-f ${where}"
    fi
  else
    where='--global'
  fi

  [ -n "$email" ] && git config $replace $where user.email "$email"
  [ -n "$name" ]  && git config $replace $where user.name "$name"

  while [ $# -ge 2 ] ; do
    echo "==>" git config $replace $where "$1" "$2" 1>&2
    git config $replace $where "$1" "$2"
    echo '---'
    shift 2
  done
}
