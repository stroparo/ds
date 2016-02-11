# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Devel functions

# Function genssh - generate id_rsa if none present for the current user.
unset genssh
genssh () {
    # Create an ssh key if there is none:
    [ ! -e "${HOME}"/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -C "${email}"
}

# ##############################################################################
# Git

# Function gg - exec git for all repos descending from current directory.
# Syntax: [-c command] [command subcommands arguments etc.]
unset gg
gg () {

    pnamesave
    pname=gg
    typeset gitcmd='git'
    typeset usage="Usage: [-c newCommandInsteadOfGit] [options] [args]"

    while getopts ':c:h' opt ; do
        case "${opt}" in
        c) gitcmd="${OPTARG}" ;;
        h) elog -i "${usage}" ; OPTIND=1 ; return ;;
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
    pnamerestore
}

# Function gitclones - Clone repos passed in the argument, one per line (quote it).
# Syntax: {repositories-one-per-line}
unset gitclones
gitclones () {

    pnamesave
    pname=gitclones

    while read repo ; do

        if [ ! -d "$(basename "${repo%.git}")" ] ; then
            if ! git clone "${repo}" ; then
                elog -f "Failed cloning '${repo}' repository."
                return 1
            fi
        else
            elog -s "'$(basename "${repo%.git}")' repository already exists."
        fi

        echo '' 1>&2

    done <<EOF
${1}
EOF

    pnamerestore
}

# Function gitconfig - configure git.
# Syntax: {email} {name} [other git config --global options]
# Example: gitconfig "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'
unset gitconfig
gitconfig () {

    pnamesave
    pname=gitconfig
    typeset email gitfile name

    # Parse options:
    while getopts ':e:f:n:' opt ; do
        case "${opt}" in
        e) email="${OPTARG}" ;;
        f) gitfile="${OPTARG}" ;;
        n) name="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND=1

    _any_null "${email}" "${name}" && elog -f "Must pass an email and a name." && return 1
    _any_not_w "${gitfile}" && elog -f "Must pass writeable file to -f option." && return 1

    if [ -w "${gitfile}" ] ; then
        [ -n "${email}" ] && git config -f "${gitfile}" user.email "${email}"
        [ -n "${name}" ] &&  git config -f "${gitfile}" user.name "${name}"
        for i in "$@" ; do git config -f "${gitfile}" ${1} ; done
    else
        [ -n "${email}" ] && git config --global user.email "${email}"
        [ -n "${name}" ] &&  git config --global user.name "${name}"
        for i in "$@" ; do git config --global ${1} ; done
    fi

    pnamerestore
}

# Function gpall - pushes current directory repo to all of its remotes.
unset gpall
gpall () {

    pnamesave
    pname=gpall

    for i in $(git remote); do
        elog -i "Pushing to remote '${i}' .."
        git push "${i}"
    done

    pnamerestore
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

