# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Networking facilities

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

# Function sshkeygenrsa - generate id_rsa if none present for the current user.
unset sshkeygenrsa
sshkeygenrsa () {
    typeset comment="$1"
    typeset keypath="${HOME}/.ssh/id_rsa"

    if [ -e "${keypath}" ] && \
        ! userconfirm "Default '${keypath}' key already exists, enter another path?"
    then
        return
    fi

    while [ -e "${keypath}" ] ; do
        userinput "Type a path that still does not exist for your key"
        keypath="${userinput}"
    done

    while [ -z "${comment}" ] ; do
        userinput 'SSH key comment (email, name or whatever)'
        comment="${userinput}"
    done

    if ssh-keygen -t rsa -b 4096 -C "${comment:-mykey}" -f "${keypath}" ; then
        # Call the agent to add the newly generated key:
        sourcefiles ${DS_VERBOSE:+-v} -t "${DS_HOME}/sshagent.sh"
    fi
}
