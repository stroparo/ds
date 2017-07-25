# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Ops routines

edithosts () { sudo ${EDITOR} /etc/hosts ; }
editrcshells () { ${VISUAL} ~/.{ba,z}shrc || ${EDITOR} ~/.{ba,z}shrc ; }
editsshauth () { mkdir ~/.ssh 2>/dev/null ; vi ~/.ssh/authorized_keys ; }
mountiso () { sudo mount -o loop -t iso9660 "$@" ; }
pgr () { ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})" ; }
psef () { ps -ef ; }
psefnoshells () { ps -ef | grep -v bash | grep -v zsh | grep -v sshd ; }
psefuser () { ps -ef | grep "${USER}" ; }
psfu () { ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" ; }
rundropbox () { env DBUS_SESSION_BUS_ADDRESS='' ~/.dropbox-dist/dropboxd & }
runsshagent () { source "${DS_HOME}/sshagent.sh" ; }

# Services
runapache () { sudo "/etc/init.d/apache${2:-2}" "${1:-restart}" ; }
runlamp () { "${LAMPHOME}/ctlscript.sh"         "${1:-restart}" ; }
runpg () { sudo "/etc/init.d/postgresql${2}"    "${1:-restart}" ; }

autobash () {
    appendunique \
        'if [[ $- = *i* ]] && [ -z "${BASH_VERSION}" ] ; then bash ; fi' \
        "$HOME/.profile"
}

autovi () {
    appendunique 'set -o vi' \
        "$HOME/.zshrc" \
        "$HOME/.bashrc" \
        "$HOME/.profile"
}

autozsh () {
    appendunique \
        'if [[ $- = *i* ]] && [ -z "${ZSH_VERSION}" ] ; then zsh ; fi' \
        "$HOME/.profile"
}

pgralert () {
    # Info: Awaits found processes to finish then starts beeping until interrupted.

    while pgr "${1}" > /dev/null ; do sleep 1 ; done
    while true ; do echo '\a' ; sleep 8 ; done
}

psfunoshells () {
    ps -fu "${UID:-$(id -u)}" -U "${UID:-$(id -u)}" \
    | grep -v bash \
    | grep -v zsh \
    | grep -v sshd
}

setlogdir () {
    # Info: Create and check log directory.
    # Syntax: {log-directory}

    typeset logdir="${1}"

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        echo "FATAL: '$logdir' log dir unavailable." 1>&2
        return 10
    fi
}

# ##############################################################################
# IBM AIX platform

if [[ $(uname) = *[Aa][Ii][Xx]* ]] ; then
    psft () { ps -fT1 ; }
    psftu () { ps -fT1 | awk "\$1 ~ /^$USER$/" ; }
fi

# ##############################################################################
