# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Devel functions

# Function gitfindexec: exec git for all repos descending of current directory.
# Syntax: [-c command] [command subcommands arguments etc.]
gitfindexec () {
  typeset gitcmd='git'

  while getopts ':c:h' opt ; do
    case "${opt}" in
      c) gitcmd="${OPTARG}" ;;
      h) echo 'gg [-c newCommandInsteadOfGit] [options] [args]' ; OPTIND=1 ; return ;;
    esac
  done
  shift $((OPTIND-1)) ; OPTIND=1

  while read gitdir; do
    echo ''
    cd "${gitdir%/.git}"
    echo "#### For git repo '${PWD}', execute:"
    echo '$' "${gitcmd}" "$@"
    eval ${gitcmd} "$@"
    cd - >/dev/null
  done <<EOF
$(find . -type d -name ".git" | sort)
EOF

  unset gitcmd
}

# Function gitpush2all: pushes current directory repo to all of its remotes.
unset gitpush2all
gitpush2all () {
  for i in $(git remote); do
    echo ">>>> pushing to remote ${i}.."
    git push "${i}"
  done
  echo '>>>> done.'
}

# Function supg: call psql via su - postgres, at the given port and user.
# Syntax: [port=5432] [user=postgres]
supg () {
  sudo su - postgres -c "psql -p ${1:-5432} -U ${2:-postgres}"
}

