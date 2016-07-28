# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Devel functions

# Function grepfu - Greps the list of available shell functions in current session.
unset grepfu
grepfu () {
    typeset -F | egrep -i "$@"
}

# ##############################################################################
# Git

# Function gitr - exec git for all repos descending from current directory.
# Syntax: [-c command] [-s] [command subcommands arguments etc.]
# Remark: GGIGNORE global can have an egrep regex for git repos to be ignored.
# Rmk #2: -s causes the command to be displayed only when its output is non-empty.
unset gitr
gitr () {
    typeset oldind="${OPTIND}"
    typeset pname=gitr

    typeset cmdout
    typeset gitcmdmsg
    typeset gitcmd='git'
    typeset statusopt=false
    typeset usage="Usage: [-c newCommandInsteadOfGit] [-s] [command args]"

    OPTIND=1
    while getopts ':c:hs' opt ; do
        case "${opt}" in
        c) gitcmd="${OPTARG}";;
        h) elog -i -n "${pname}" "${usage}" ; OPTIND=1 ; return ;;
        s) statusopt=true;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    typeset gitrcmd="$(cat <<EOF
cd {}/..

gitcmdmsg="==> ${gitcmd} $@ # At '\${PWD}'"

if ${statusopt} ; then

    cmdout="\$(eval ${gitcmd} $@ 2>&1)"

    if [ -n "\${cmdout}" ] ; then
        echo "\${gitcmdmsg}"
        echo "\${cmdout}"
        echo ''
    fi
else
    echo "\${gitcmdmsg}"
    eval ${gitcmd} $@ 2>&1
    echo ''
fi
EOF
)"

    paralleljobs -p 32 -t -z "$gitcmd" "$gitrcmd" <<EOF
$(find . -type d -name ".git" | egrep -i -v "${GGIGNORE}/[.]git" | sort)
EOF
}

# Function gitclones - Clone repos passed in the argument, one per line (quote it).
# Syntax: {repositories-one-per-line}
unset gitclones
gitclones () {
    typeset pname=gitclones

    while read repo ; do
        [ -z "${repo}" ] && continue

        if [ ! -d "$(basename "${repo%.git}")" ] ; then
            if ! git clone "${repo}" ; then
                elog -f -n "${pname}" "Failed cloning '${repo}' repository."
                return 1
            fi
        else
            elog -s -n "${pname}" "'$(basename "${repo%.git}")' repository already exists."
        fi

        echo '' 1>&2
    done <<EOF
${1}
EOF
}

# Function gitconfig - configure git.
# Syntax: {email} {name} [other git config --global options]
# Example: gitconfig "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'
unset gitconfig
gitconfig () {
    typeset oldind="${OPTIND}"
    typeset pname=gitconfig
    typeset email gitfile name

    OPTIND=1
    while getopts ':e:f:n:' opt ; do
        case "${opt}" in
        e) email="${OPTARG}" ;;
        f) gitfile="${OPTARG}" ;;
        n) name="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    _any_null "${email}" "${name}" && elog -f -n "${pname}" "Must pass an email and a name." && return 1
    _any_not_w "${gitfile}" && elog -f -n "${pname}" "Must pass writeable file to -f option." && return 1

    if [ -w "${gitfile}" ] ; then
        [ -n "${email}" ] && git config -f "${gitfile}" user.email "${email}"
        [ -n "${name}" ] &&  git config -f "${gitfile}" user.name "${name}"
        for i in "$@" ; do git config -f "${gitfile}" ${1} ; done
    else
        [ -n "${email}" ] && git config --global user.email "${email}"
        [ -n "${name}" ] &&  git config --global user.name "${name}"
        for i in "$@" ; do git config --global ${1} ; done
    fi
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

