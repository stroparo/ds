# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Devel functions

# ##############################################################################
# Git

# Function gg - exec git for all repos descending from current directory.
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

# Function gitclones - Clone repos passed in the argument, one per line (quote it).
# Syntax: {repositories-one-per-line}
unset gitclones
gitclones () {

    while read repo ; do

        if [ ! -d "$(basename "${repo%.git}")" ] ; then
            if ! git clone "${repo}" ; then
                echo "Failed cloning '${repo}' repository. Aborted sequence." 1>&2
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

# Function gitconfig - Configures ssh key if there is none, and setup git config.
# Syntax: {email} {name} [other git config --global options]
# Example: gitconfig "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'
unset gitconfig
gitconfig () {

    typeset gitfile=''

    # Parse options:
    while getopts ':f:' opt ; do
        case "${opt}" in
        f) gitfile="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND=1

    typeset email="${1}"
    typeset name="${2}"
    shift 2

    # Verify arguments:
    if [ -z "${email}" -o -z "${name}" ] ; then
        echo 'FATAL: Must pass an email and a name.' 1>&2
        return 1
    fi

    if [ -n "${gitfile}" -a ! -w "${gitfile}" ] ; then
        echo 'FATAL: Must pass writeable git config file to -f option.' 1>&2
        return 1
    fi

    # Create an ssh key if there is none:
    [ ! -e "${HOME}"/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -C "${email}"

    if [ -n "${gitfile}" ] ; then
        git config -f "${gitfile}" user.name "${name}"
        git config -f "${gitfile}" user.email "${email}"
        for i in "$@" ; do git config -f "${gitfile}" ${1} ; shift ; done
    else
        git config --global user.name "${name}"
        git config --global user.email "${email}"
        for i in "$@" ; do git config --global ${1} ; shift ; done
    fi
}

# Function gpall - pushes current directory repo to all of its remotes.
unset gpall
gpall () {
    for i in $(git remote); do
        echo "=> Pushing to remote ${i}.."
        git push "${i}" && echo "=> Pushed to remote ${i}."
    done
}

# ##############################################################################
# PostgreSQL

# Function supg - call psql via su - postgres, at the given port and user.
# Syntax: [port=5432] [user=postgres]
unset supg
supg () {
    sudo su - postgres -c "psql -p ${1:-5432} -U ${2:-postgres}"
}

# ##############################################################################

