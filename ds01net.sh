# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking facilities

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

    pushl -e "$envre" -d '.ds/scripts' -f "*" -x "$exc" "${DS_HOME}/scripts" "$@"
}

# Function screenb - run a bash shell in a screen session.
# Syntax: [sessionname]
unset screenb
screenb () {
    screen -S "${1:-screenbash}" bash
}

# Function screenk - run a ksh shell in a screen session.
# Syntax: [sessionname]
unset screenk
screenk () {
    env ENV="${HOME}/.kshrc" screen -S "${1:-screenksh}" ksh
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

    if ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" ; then
        # Call the agent to add the newly generated key:
        sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
    fi
}
