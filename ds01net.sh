# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking facilities

# Syntax: getcookiesmozilla {agent_cookies_sqlite_filename} {target_cookies_filename} {domain_regex}
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

# Function pushds
# Purpose:
#   Push ds scripts and source files to envs pointed to by arguments.
pushds () {

    typeset oldind="$OPTIND"

    typeset envre
    typeset exc

    OPTIND=1
    while getopts ':e:x:' opt ; do
        case ${opt} in
        e) envre="$OPTARG";;
        x) exc="$OPTARG";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="$oldind"

    pushl -r -e "$envre" -d '.ds/' -f "${DS_GLOB}" -x "$exc" "${DS_HOME}" "$@"

    pushl -r -e "$envre" -d '.ds/scripts' -f "*" -x "$exc" "${DS_HOME}/scripts" "$@"
}

# Function sbash - run a bash shell in a screen session.
# Syntax: [sessionname]
unset sbash
sbash () {
    screen -S "${1:-sbash}" bash
}

# Function sksh - run a ksh shell in a screen session.
# Syntax: [sessionname]
unset sksh
sksh () {
    env ENV="${HOME}/.kshrc" screen -S "${1:-sksh}" ksh
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

# Function iwf - Show iwconfig and ifconfig in given interface (1st arg; default=wlan0).
unset iwf
iwf () {
    iwconfig "${1:-wlan0}"
    ifconfig "${1:-wlan0}"
}
