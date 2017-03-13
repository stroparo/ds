# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking

# Oneliners
iwf () { iwconfig ; ifconfig ; }

getcookiesmozilla () {
    # Info: Get firefox cookies & write them to a file in old netscape (or wget) format.
    # Syntax: {mozilla's cookies sqlite db} {target cookies filename} {domain pattern/regex}

    typeset agent_cookies="${1}"
    typeset target_cookies="${2}"
    typeset inet_domain_pattern="${3}"

    if [ ! -e "${target_cookies}" ] ; then
        sqlite3 "${agent_cookies}" <<EOF
.output ${target_cookies}
.mode tabs
-- select basedomain, 'TRUE', path, issecure, expiry, name, value from moz_cookies where baseDomain like '%domain%';
select basedomain, 'TRUE', path, 'FALSE', expiry, name, value from moz_cookies where baseDomain like '%${inet_domain_pattern}%';
.quit
EOF
    fi
}

pushds () {
    # Info:
    #   Push ds scripts and source files to envs pointed to by arguments, packed into
    #   an archive whose filename starts with DS directory's basename eg 'ds.tar.gz'.
    # Option -d new-ds-home overrides DS_HOME as the default DS directory.

    typeset dsarchive dsbase dsdir dsparent
    typeset dsarchivedir="$HOME"
    typeset envre
    typeset extension='.tar.gz'
    typeset excludeERE='====@@@@DUMMYEXCLUDE@@@@===='
    typeset oldind="$OPTIND"
    typeset optdirs="${DS_HOME}"

    OPTIND=1
    while getopts ':d:e:x:' opt ; do
        case ${opt} in
        d) optdirs="$OPTARG";;
        e) envre="$OPTARG";;
        x) excludeERE="$OPTARG";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="$oldind"

    while read dsdir ; do

        if [ -n "${dsdir}" ] && [ ! -d "${dsdir}" -o ! -r "${dsdir}" ] ; then
            echo "FATAL: dsdir='${dsdir}' is not a valid directory." 1>&2
            return 1
        fi

        dsarchive="${dsarchivedir}/$(basename "${dsdir}")${extension}"
        dsbase="$(basename "${dsdir}")"
        dsparent="$(cd "${dsdir}" && cd .. && echo "$PWD")"

        if [ -z "$dsbase" -o -z "$dsparent" ] ; then
            echo "FATAL: Could not obtain dirname and basename of dsdir='${dsdir}'." 1>&2
            return 1
        fi

        tar -C "${dsparent}" -cf - \
            $(cd "${dsparent}" && find "${dsbase}" -type f | egrep -v "/[.]git|$excludeERE") | \
            gzip -c - > "${dsarchive}"
    done <<EOF
$(echo "$optdirs" | tr -s , '\n')
EOF

    pushl -r -e "$envre" -f "ds*${extension}" -s "${dsarchivedir}" "$@"
    res=$?
    ([ "$res" -eq 0 ] && cd "${dsarchivedir}" && rm -f ds*"${extension}")
    return ${res:-1}
}

sshkeygenrsa () {
    # Info: Generate id_rsa if none present for the current user.
    # Syntax: {comment} [keypath]

    typeset comment="$1"
    typeset keypath="${2:-${HOME}/.ssh/id_rsa}"

    while [ -z "${comment}" ] ; do
        userinput 'SSH key comment (email, name or whatever)'
        comment="${userinput}"
    done

    while [ -e "${keypath}" ] ; do
        userinput "Key '${keypath}' already exists, type another path"
        keypath="${userinput}"
    done

    if [[ $keypath = $HOME/.ssh* ]] && [ ! -d "$HOME/.ssh" ] ; then
        mkdir "$HOME/.ssh"
    fi

    if [ ! -d "$(dirname "$keypath")" ] ; then
        echo "FATAL: No directory available to store '$keypath'." 1>&2
        return 1
    fi

    if ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" ; then
        # Call the agent to add the newly generated key:
        sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
    fi
}

# ##############################################################################
