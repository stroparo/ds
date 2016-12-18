# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Git routines

gitclones () {
    # Info: Clone repos passed in the argument, one per line (quote it).
    # Syntax: {repositories-one-per-line}

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

gitconfig () {
    # Info: Configure git.
    # Syntax: {email} {name} [other git config --global options]
    # Example: gitconfig "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'

    typeset pname=gitconfig
    typeset email gitfile name

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':e:f:n:' opt ; do
        case "${opt}" in
        e) email="${OPTARG}" ;;
        f) gitfile="${OPTARG}" ;;
        n) name="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    if _any_null "${email}" "${name}" ; then
        elog -f -n "${pname}" "Must pass an email and a name."
        return 1
    fi
    if [ -n "$gitfile" ] && _any_not_w "${gitfile}"; then
        elog -f -n "${pname}" "Must pass writeable file to -f option."
        return 1
    fi

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

