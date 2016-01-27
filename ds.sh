#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# DS reserved objects

export DS_HOME="${1:-${HOME}/.ds}"
export DS_VERBOSE
export DS_VERSION='DS version 0.1.0 - 2016-01-18 22:30'

# Function dsversion: displays the Daily Shells header and version.
#  Stdout is fully redirected to stderr.
dsversion () {
    echo "Daily Shells - ${DS_VERSION}" 1>&2
}

# Function dshelp: displays the Daily Shells help information.
#  Stdout is fully redirected to stderr.
dshelp () {
    echo 'DS - Daily Shells Library - Help

Commands:

dshelp:     displays this help messsage.
dsinfo:     displays environment information.
dsversion:  displays the version of this Daily Shells instance.
' 1>&2
}

# Function dsinfo: this displays DS environment information.
#  It might be overriden by your own fork.
#  Stdout is fully redirected to stderr.
dsinfo () {
    dsversion
    echo "DS_HOME='${DS_HOME}'" 1>&2
}

# ##############################################################################
# Basic functions

# Function aliasnoext: pick {argument}/*sh and yield aliases without extension.
# Syntax: {directory}1+
unset aliasnoext
aliasnoext () {

    typeset verbose

    # Options:
    while getopts ':v' opt ; do
        case "${opt}" in
        v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for dir in "$@" ; do
        [ -d "${dir}" ] && \
        while read script ; do
            if [ -x "${script}" ] ; then
                aliasname="${script##*/}"
                aliasname="${aliasname%%.*}"
                eval unalias "${aliasname}" 2>/dev/null
                eval alias "${aliasname}=${script}"
                if [ -n "${verbose}" ] ; then
                    eval type "${aliasname}"
                fi
            fi
        done <<EOF
$(ls -1 "${dir}"/*sh 2>/dev/null)
EOF
    done
}

# Function cyg - cd to the disk drive letter argument; fails if not in cygwin.
# Syntax: cyg {a|b|c|d|e|f|...}
unset cyg 2>/dev/null
cyg () {
    [[ "$(uname -a)" = *ygwin* ]] || return 1
    d /cygdrive/"${1:-c}" -Ah
}

# Function ckenv - check number of arguments and sets hasgnu ("GNU is not Unix").
# Syntax: {min-args} [max-args=min-args]
unset ckenv
ckenv () {
    typeset args_slice_min="${1}"
    typeset args_slice_max="${2:-1}"
    shift 2

    if ! [ "${#}" -ge "${args_slice_min:-0}" -a \
           "${#}" -le "${args_slice_max:-1}" ] ; then
        echo "Bad arguments.." 1>&2
        echo "${usage:-There was no 'usage' variable set.}" 1>&2
        return 1
    fi

    # hasgnu - "has GNU?" portability indicator
    find --version 2> /dev/null | grep -i -q 'gnu'
    if [ "$?" -eq 0 ] ; then
        export hasgnu=true
    fi
}

# Function d - change directory and execute pwd followed by an ls.
# Syntax: {directory}
unalias d 2>/dev/null
unset d
d () {
    dir="${1}"
    shift

    cd "${dir}" || return 1
    pwd 1>&2
    ls -Fl "$@" 1>&2
}

# Function echoe - echoes a string to standard error.
unset echoe
echoe () {
    echo "$@" 1>&2
}

# Function getnow: setup NOW* and TODAY* environment variables.
unset getnow
getnow () {
    export NOW_HMS="$(date '+%OH%OM%OS')"
    export NOW_YMDHM="$(date '+%Y%m%d%OH%OM')"
    export NOW_YMDHMS="$(date '+%Y%m%d%OH%OM%OS')"
    export TODAY="$(date '+%Y%m%d')"
    export TODAY_ISO="$(date '+%Y-%m-%d')"
}

# Function loop - pass a command to be executed every secs seconds.
# Syntax: [-d secs] command
unset loop
loop () {
    typeset interval=10

    while getopts ':d:' opt ; do
        case "${opt}" in
        d)
            interval="${OPTARG}"
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    while true ; do
        clear 2>/dev/null || echo '' 1>&2
        echo "Looping thru every ${interval} seconds.." 1>&2
        echo "Command:" "$@" 1>&2
        $@
        sleep "${interval}" 2>/dev/null \
        || sleep 10 \
        || break
    done
}

# Function pathmunge: prepend (-a causes to append) directory to PATH global.
# Syntax: {path}1+
unset pathmunge
pathmunge () {
    typeset pathmunge_after
  
    while getopts ':a' opt ; do
        case "${opt}" in
        a) pathmunge_after=1 ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND=1
  
    for i in "$@" ; do
        if [ -n "${pathmunge_after}" ] ; then
            PATH="${PATH}:${i}"
        else
            PATH="${i}:${PATH}"
        fi
    done
    PATH="${PATH#:}"
    PATH="${PATH%:}"
  
    unset opt pathmunge_after
}

# Function sourcefiles: each arg is a glob; source all glob expanded paths.
#  Tilde paths are accepted, as the expansion is yielded
#  via eval. Expanded directories are ignored.
#  Stdout is fully redirected to stderr.
sourcefiles () {

    typeset name
    typeset tolerant
    typeset verbose

    # Options:
    while getopts ':n:tv' opt ; do
        case "${opt}" in
        n) name="${OPTARG}";;
        t) tolerant=true;;
        v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for globpattern in "$@" ; do

        if ! ls -1d ${globpattern} >/dev/null 2>&1 ; then
            echo "Ignored bad listing for glob '${globpattern}'." 1>&2
        fi

        exec 4<&0

        while read src; do
            if [ -z "${src}" -o -d "${src}" ] ; then
                continue
            fi

            if [ -n "${verbose}" ] ; then
                echo "=> Sourcing ${name:+${name} - }'${src}' ..." 1>&2
            fi

            # Source op:
            if [ -r "${src}" ] ; then
                . "${src}" 1>&2
            fi

            if [ -z "${tolerant}" -a "$?" -ne 0 ] ; then
                echo "Aborted non-tolerant sourcing attempt${name:+ for ${name}}." 1>&2
                return 1
            elif [ -n "${verbose}" ] ; then
                echo "=> Source finished${name:+ for ${name}}." 1>&2
            fi
        done <<EOF
$(eval ls -1d ${globpattern} 2>/dev/null)
EOF

    done
}

# ##############################################################################
# Calls to routines

# Initialize DS:
[ -n "${DS_VERBOSE}" ] && dsinfo
sourcefiles -t ${DS_VERBOSE:+-v} "${DS_HOME}/aliases*sh" "${DS_HOME}/f*sh"
sourcefiles -t ${DS_VERBOSE:+-v} "${DS_HOME}/ds-post.sh"
aliasnoext "${DS_HOME}/scripts"

# Etcetera
if [ -r "${DS_HOME}/sshagent.sh" ] ; then
    sourcefiles ${DS_VERBOSE:+-v} "${DS_HOME}/sshagent.sh"
fi
