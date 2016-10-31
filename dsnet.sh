# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking

# Function getcookiesmozilla - Get firefox cookies and write them to a
#   file in old netscape format, suitable for usage with wget.
# Syntax: {mozilla's cookies sqlite db} {target cookies filename} {domain pattern/regex}
getcookiesmozilla () {
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

# Function iwf - Show iwconfig and ifconfig in given interface (1st arg; default=wlan0).
iwf () { iwconfig "${1:-wlan0}" ; ifconfig "${1:-wlan0}" ; }

# Function pushds
# Purpose:
#   Push ds scripts and source files to envs pointed to by arguments packed into.
#   an archive whose filename starts with DS directory's basename eg 'ds.tar.gz'.
# Option -d new-ds-home overrides DS_HOME as the default DS directory.
pushds () {
    typeset dsarchive dsbase dsdir dsparent
    typeset dsarchivedir="$HOME"
    typeset envre
    typeset extension='.tar.gz'
    typeset excere='====@@@@DUMMYEXCLUDE@@@@===='
    typeset oldind="$OPTIND"
    typeset optdirs="${DS_HOME}"

    OPTIND=1
    while getopts ':d:e:x:' opt ; do
        case ${opt} in
        d) optdirs="$OPTARG";;
        e) envre="$OPTARG";;
        x) excere="$OPTARG";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="$oldind"

    for dsdir in $(echo "$optdirs" | tr -s , ' ') ; do

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
            $(cd "${dsparent}" && find "${dsbase}" -type f | egrep -v "/[.]git|$excere") | \
            gzip -c - > "${dsarchive}"
    done

    pushl -r -e "$envre" -f "ds*${extension}" -s "${dsarchivedir}" "$@"
    res=$?
    (cd "${dsarchivedir}" && rm -f ds*"${extension}")
    return ${res:-1}
}

# Function sshkeygenrsa
# Purpose:
#   Generate id_rsa if none present for the current user.
# Usage:
# {comment} [keypath]
unset sshkeygenrsa
sshkeygenrsa () {

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
        elog -n "$pname" "No directory available to store '$keypath'."
        return 1
    fi

    if ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" ; then
        # Call the agent to add the newly generated key:
        sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
    fi
}

# ##############################################################################
