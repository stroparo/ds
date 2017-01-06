# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Ops routines

autovimode () { appendunique 'set -o vi' "$HOME/.bashrc" "$HOME/.profile" ; }

autobash () {
    appendunique 'if [[ $- = *i* ]] && [ -z "${BASH_VERSION}" ] ; then bash ; fi' \
        "$HOME/.profile"
}

mountiso () {
    sudo mount -o loop -t iso9660 "$@"
}

pgr () {
    # Info: pgr is similar to pgrep

    ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})"
}

pgralert () {
    # Info: Awaits found processes to finish then starts beeping until interrupted.

    while pgr "${1}" > /dev/null ; do sleep 1 ; done
    while true ; do echo '\a' ; sleep 8 ; done
}

setlogdir () {
    # Info: Create and check log directory.
    # Syntax: {log-directory}

    typeset logdir="${1}"

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        echo "$pfatal '$logdir' log dir unavailable." 1>&2
        return 10
    fi
}

# ##############################################################################

