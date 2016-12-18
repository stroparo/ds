# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# DS base routines

# Globals

pfatal="FATAL:"
pinfo="INFO:"
pskip="SKIP:"
pwarn="WARN:"

# Aliases

alias cdbak='d "${DS_ENV_BAK}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias t='d "${TEMP_DIRECTORY}" -A'

# Functions

dsinfo () { dsversion ; echo "DS_HOME='${DS_HOME}'" 1>&2 ; }
dss () { ls -1 "$DS_HOME"/scripts/* | sed -e 's#.*/##' ; }
dsversion () { echo "Daily Shells - ${DS_VERSION}" 1>&2 ; }

dshelp () {
    echo 'DS - Daily Shells Library - Help

dsf - list daily shell functions
dss - list daily shell scripts
dshelp - display this help messsage
dsinfo - display environment information
dsversion - display the version of this Daily Shells instance
' 1>&2
}

dsf () {

    typeset filename item items itemslength

    for i in $(ls -1 "$DS_HOME"/functions/*sh) ; do

        items=$(egrep '^ *(function [_a-zA-Z0-9][_a-zA-Z0-9]* *[{]|[_a-zA-Z0-9][_a-zA-Z0-9]* *[(][)] *[{])' "$i" /dev/null | \
                    sed -e 's#^.*functions/##' -e  's/[(][)].*$//')
        filename=$(echo "$items" | head -n 1 | cut -d: -f1)
        items=$(echo "$items" | cut -d: -f2)
        itemslength=$(echo "$items" | wc -l | awk '{print $1;}')

        if [ -n "$items" ] ; then
            for item in $(echo "$items" | cut -d: -f2) ; do
                echo "$item in $filename"
            done
        fi
    done | sort
}

# ##############################################################################
# Base routines

unalias d 2>/dev/null
d () {
    # Info: Change directory and execute pwd followed by an ls.
    # Syn: {directory}

    dir="${1}"
    shift

    cd "${dir}" || return 1
    pwd 1>&2
    ls -Fl "$@" 1>&2

    if which git >/dev/null 2>&1 && [ -e "${PWD}/.git" ]; then
        git status -s
    fi
}

elog () {
    # Info: Echo a string to standard error.

    typeset msgtype="INFO"
    typeset pname
    typeset verbosecondition

    typeset oldind="$OPTIND"
    OPTIND=1
    while getopts ':dfin:svw' opt ; do
        case "${opt}" in
            d) msgtype="DEBUG" ;;
            f) msgtype="FATAL" ;;
            i) msgtype="INFO" ;;
            n) pname="${OPTARG}" ;;
            s) msgtype="SKIP" ;;
            v) verbosecondition=true ;;
            w) msgtype="WARNING" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    if [ -z "${verbosecondition}" -o -n "${DS_VERBOSE}" ] ; then
        echo "${pname:+${pname}:}${msgtype:+${msgtype}:}" "$@" 1>&2
    fi
}

sourcefiles () {
    # Info: Each arg is a glob; source all glob expanded paths.
    #  Tilde paths are accepted, as the expansion is yielded
    #  via eval. Expanded directories are ignored.
    #  Stdout is fully redirected to stderr.

    typeset pname='sourcefiles'
    typeset quiet=false
    typeset tolerant=false
    typeset verbose=false

    typeset name src srcs srcresult
    typeset nta='Non-tolerant abort.'

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':n:qtv' opt ; do
        case "${opt}" in
            n) name="${OPTARG}";;
            q) quiet=true;;
            t) tolerant=true;;
            v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    if test -n "${name}" && $verbose && ! $quiet ; then
        echo "==> Sourcing group '${name}'" 1>&2
    fi

    for globpattern in "$@" ; do

        srcs="$(eval ls -1d ${globpattern} 2>/dev/null)"

        if [ -z "$srcs" ] ; then
            if ! ${tolerant} ; then
                $quiet || echo "$pfatal $nta Bad glob." 1>&2
                return 1
            fi
            continue
        fi

        exec 4<&0

        while read src ; do

            $verbose && ! $quiet && echo "==> Sourcing '${src}' ..." 1>&2

            if [ -r "${src}" ] ; then
                . "${src}" 1>&2
            else
                $quiet || echo "$warn '${src}' is not readable." 1>&2
                false
            fi
            srcresult=$?

            if [ "${srcresult}" -ne 0 ] ; then
                if ! $tolerant ; then
                    $quiet || elog -f -n "${pname}" "${nta} Sourcing '${src}'."
                    return 1
                fi

                $quiet || elog -w -n "${pname}" "Tolerant fail for '${src}'."
            else
                if $verbose && ! $quiet ; then
                    elog -n "${pname}" "=> '${src}' completed successfully."
                fi
            fi
        done <<EOF
${srcs}
EOF
    done
    if $verbose && test -n "${name}" ; then
        elog -n "${pname}" "GROUP COMPLETE."
    fi
}

# ##############################################################################
# Testing routines

_is_interactive () { [[ "$-" = *i* ]] ; }

_is_aix () { [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; }
_is_cygwin () { [[ "$(uname -a)" = *[Cc]ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] || _is_debian || _is_ubuntu ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }

_all_dirs_rwx () {
    # Tests if any of the directory arguments are neither readable nor w nor x.
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
            return 1
        fi
    done
    return 0
}
_all_dirs_r () { for i in "$@" ; do [ ! -d "${1}" -o ! -r "${1}" ] && return 1 ; done ; return 0 ; }
_all_dirs_w () { for i in "$@" ; do [ ! -d "${1}" -o ! -w "${1}" ] && return 1 ; done ; return 0 ; }
_all_exist () { for i in "$@" ; do [ ! -e "${1}" ] && return 1 ; done ; return 0 ; }
_all_not_null () { for i in "$@" ; do [ -z "${i}" ] && return 1 ; done ; return 0 ; }
_all_r () { for i in "$@" ; do [ ! -r "${1}" ] && return 1 ; done ; return 0 ; }
_all_w () { for i in "$@" ; do [ ! -w "${1}" ] && return 1 ; done ; return 0 ; }
_any_dir_not_r () { ! _all_dirs_r "$@" ; }
_any_dir_not_rwx () { ! _all_dirs_rwx "$@" ; }
_any_dir_not_w () { ! _all_dirs_w "$@" ; }
_any_exists () { for i in "$@" ; do [ -e "${1}" ] && return 0 ; done ; return 1 ; }
_any_not_exists () { ! _all_exist "$@" ; }
_any_not_r () { ! _all_r "$@" ; }
_any_not_w () { ! _all_w "$@" ; }
_any_null () { for i in "$@" ; do [ -z "${i}" ] && return 0 ; done ; return 1 ; }

ckapt () {
    which apt > /dev/null || which apt-get > /dev/null
}

ckaptitude () {
    aptitude -h > /dev/null || \
        (sudo apt-get update && sudo apt-get install -y aptitude)
}

ckenv () {
    # Info: Checks number of arguments and sets hasgnu ("GNU is not Unix").
    # Syn: {min-args} [max-args=min-args]

    typeset args_slice_min="${1:-0}"
    typeset args_slice_max="${2:-0}"
    shift 2

    if [ "${#}" -lt "${args_slice_min}" -o \
           "${#}" -gt "${args_slice_max}" ] ; then
        echo "Bad arguments:" "$@" 1>&2
        return 1
    fi

    # hasgnu - "has GNU?" portability indicator
    if find --version 2> /dev/null | grep -i -q 'gnu' ; then
        export hasgnu=true
    fi
}

# ##############################################################################
# Retrofit
paralleljobs () { dsp "$@" ; }

# ##############################################################################
