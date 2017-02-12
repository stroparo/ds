# DS - Daily Shells Library
# License:
#    See README.md document in projects page at
#    https://github.com/stroparo/ds

# ##############################################################################
# Git routines

gitclones () {
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

dsgitconfig () {
    # Info: Configure git.
    # Syntax: {email} {name} [other git config --global options]
    # Example: dsgitconfig "john@doe.com" "John Doe" 'core.autocrlf false' 'push.default simple'

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

    if [ -n "$gitfile" ] && _any_not_w "${gitfile}"; then
        echo "FATAL: Must pass writeable file to -f option." 1>&2
        return 1
    fi

    if [ -w "${gitfile}" ] ; then
        [ -n "${email}" ] && git config -f "${gitfile}" user.email "${email}"
        [ -n "${name}" ] &&  git config -f "${gitfile}" user.name "${name}"
        for i in "$@" ; do git config -f "${gitfile}" $(echo ${i}) ; done
    else
        [ -n "${email}" ] && git config --global user.email "${email}"
        [ -n "${name}" ] &&  git config --global user.name "${name}"
        for i in "$@" ; do git config --global $(echo ${i}) ; done
    fi
}

dsgitdeploy () {
    # Info: Configures git. Also handles windows installation if in cygwin.
    # Syn: List of quoted params for dsgitconfig(), eg:
    #   "'core.autocrlf false' 'push.default simple'"

    which git >/dev/null 2>&1 || aptinstall -y 'git-core'
    which git >/dev/null 2>&1 || return 1

    readmyemail
    readmysign
    [ -e ~/.ssh/id_rsa ] || sshkeygenrsa "${MYEMAIL}"

    eval dsgitconfig -e "\"${MYEMAIL}\"" -n "\"${MYSIGN}\"" $(echo "$1")

    if _is_cygwin ; then
        typeset cyggitconfig="$(cygpath "$USERPROFILE")/.gitconfig"
        touch "$cyggitconfig"

        dsgitconfig 'core.filemode false'
        dsgitconfig -f "${cyggitconfig}" 'core.filemode false'

        eval dsgitconfig \
            -f "\"${cyggitconfig}\"" \
            -e "\"${MYEMAIL}\"" \
            -n "\"${MYSIGN}\"" \
            $(echo "$1")
    fi
}

# ##############################################################################

