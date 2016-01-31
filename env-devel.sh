# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Devel functions

# Function gg: exec git for all repos descending of current directory.
# Syntax: [-c command] [command subcommands arguments etc.]
gg () {
    typeset gitcmd='git'

    while getopts ':c:h' opt ; do
        case "${opt}" in
            c) gitcmd="${OPTARG}" ;;
            h) echo "${0} [-c newCommandInsteadOfGit] [options] [args]" ; OPTIND=1 ; return ;;
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

# Function gpushall: pushes current directory repo to all of its remotes.
unset gpushall
gpushall () {
    for i in $(git remote); do
        echo "=> Pushing to remote ${i}.."
        git push "${i}" && echo "=> Pushed to remote ${i}."
    done
}

# Function supg: call psql via su - postgres, at the given port and user.
# Syntax: [port=5432] [user=postgres]
supg () {
    sudo su - postgres -c "psql -p ${1:-5432} -U ${2:-postgres}"
}

