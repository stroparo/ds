#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

export PNAME="$(basename "$0")"
export USAGE="
NAME
    ${PNAME} - exec git for all descending gits from current directory

SYNOPSIS
    ${PNAME}
    ${PNAME} -h
    ${PNAME} [-c newCommandInsteadOfGit] [-v] [command args]
    ${PNAME} -p option causes commands to be executed concurrently

DESCRIPTION

Remark:
    GGIGNORE global can have an egrep regex for git repos to be ignored.

Rmk #2:
    -v shows command even if its output is empty (pull|push not up to date).
"

# ##############################################################################
# Globals

# ##############################################################################
# Prep args

# Options:

export FULL=false
export PARALLEL=false
export PROGRAM='git'
export VERBOSE=false

OPTIND=1
while getopts ':c:fhpv' opt ; do
    case "${opt}" in
    c) export PROGRAM="${OPTARG}";;
    f) export FULL=true;;
    h) echo "$USAGE" ; exit ;;
    p) export PARALLEL=true;;
    v) export VERBOSE=true;;
    esac
done
shift $((OPTIND-1))

# ##############################################################################
# Prep

export GITCMD="$1"
shift

export GITREPOS="$(
if [ -z "$GGIGNORE" ] || ${FULL:-false} ; then
    find . -type d -name ".git"
else
    find . -type d -name ".git" | egrep -i -v "${GGIGNORE}/[.]git"
fi
)"

# ##############################################################################
# Functions

prep () {

    typeset oldpwd="$PWD"

    if ! . "${DS_HOME}/ds.sh" "${DS_HOME}" >/dev/null 2>&1 || [ -z "${DS_LOADED}" ] ; then
        echo "${PNAME}: FATAL: Could not load DS - Daily Shells." 1>&2
        echo "DS_HOME='${DS_HOME}'" 1>&2
        exit 1
    fi

    cd "$oldpwd"
}

cmdexpand () {
    if echogrep -q '^g?ss$' "$GITCMD" ; then export GITCMD='status -s'
    elif echogrep -q '^g?st$' "$GITCMD" ; then export GITCMD='status'
    elif echogrep -q '^g?l$' "$GITCMD" ; then export GITCMD='pull'
    elif echogrep -q '^g?p$' "$GITCMD" ; then export GITCMD='push'
    fi
}

setGITRCMD () {
    export GITRCMD="$(cat <<EOF
cd {}/..

export HEADERMSG="==> ${PROGRAM:-git} ${GITCMD} $@ # At '\${PWD}'"
export CMDOUT="\$(eval "${PROGRAM:-git}" "${GITCMD}" $@ 2>&1)"

if [ -z "\$CMDOUT" ] || \
    ([ "${GITCMD}" = 'pull' ] && [ "\$CMDOUT" = 'Already up-to-date.' ]) || \
    ([ "${GITCMD}" = 'push' ] && [ "\$CMDOUT" = 'Everything up-to-date' ])
then
    hasoutput=false
else
    hasoutput=true
fi

if ${VERBOSE:-false} || \${hasoutput:-false} ; then
    echo "\${HEADERMSG}"
    echo "\${CMDOUT}"
    echo ''
fi
EOF
)"
}

execCalls () {
    typeset reponame

    for repo in ${GITREPOS}; do
        reponame=${repo%.git}
        reponame=${repo##*/}
        (cd $repo/.. && \
        echo "==> ${PROGRAM:-git} ${GITCMD} $@ # At '${PWD}'" 1>&2 && \
        eval "${PROGRAM:-git}" "${GITCMD}" "$@" \
        2>&1 | tee "$DS_ENV_LOG/${PROGRAM:-git}_$(date '+%Y%m%d_%OH%OM%OS')_${reponame}.log")
    done
}

execCallsParallel () {
    (dsp -p 32 -q -t -z "$PROGRAM" "$GITRCMD" <<EOF
${GITREPOS}
EOF
)
}

gitr () {
    cmdexpand
    if ${PARALLEL} ; then
        setGITRCMD "$@"
        execCallsParallel
    else
        execCalls "$@"
    fi
}

# ##############################################################################
# Main

prep
gitr "$@"
exit "$?"