# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# DS base objects

pfatal="FATAL:"
pinfo="INFO:"
pskip="SKIP:"
pwarn="WARN:"

# Changedir:
alias cdbak='d "${DS_ENV_BAK}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias ds='d "${DS_HOME}" -Ah ; [ -n "$(git status -s)" ] && git diff'
if ! ls -h >/dev/null 2>&1 ; then
    unalias ds
    alias ds='d "${DS_HOME}" -A ; which git >/dev/null 2>&1 && [ -n "$(git status -s)" ] && git diff'
fi
alias t='d "${TEMP_DIRECTORY}" -A'

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
_any_not_r () { ! all_r "$@" ; }
_any_not_w () { ! all_w "$@" ; }
_any_null () { for i in "$@" ; do [ -z "${i}" ] && return 0 ; done ; return 1 ; }

ckapt () {
    which apt > /dev/null || which apt-get > /dev/null
}

ckaptitude () {
    aptitude -h > /dev/null || \
        (sudo apt-get update && sudo apt-get install -y aptitude)
}

# ##############################################################################
# Retrofit
paralleljobs () { dsp "$@" ; }

# ##############################################################################

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
                if $verbose ; then
                    $quiet || elog -n "${pname}" "=> '${src}' completed successfully."
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

setlogdir () {
    # Info: Create and check log directory.
    # Syntax: {log-directory}

    typeset logdir="${1}"

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        echo "$fatal '$logdir' log dir unavailable." 1>&2
        return 10
    fi
}

# ##############################################################################
# Text processing functions

catnum () { mutail -n1 "$@" | grep '^[0-9][0-9]*$' ; } # TODO rename to tailnum
echoupcase () { echo "$@" | tr '[[:lower:]]' '[[:upper:]]' ; }
locase () { tr '[[:upper:]]' '[[:lower:]]' ; }
upcase () { tr '[[:lower:]]' '[[:upper:]]' ; }

appendunique () {
    # Info: If string not present in file, append to it.
    # Syntax: string file1 [file2 ...]

    typeset msgerrforfile="appendunique: ERROR for file"
    typeset failedsome=false
    typeset text="${1}" ; shift

    for f in "$@" ; do

        [ -e "$f" ] || touch "$f"

        if ! fgrep -q "${text}" "${f}" ; then

            if ! echo "${text}" >> "${f}" ; then
                failedsome=true
                echo "${msgerrforfile} '${f}' .." 1>&2
            fi
        fi
    done

    if ${failedsome} ; then
        echo "appendunique: $fatal Text was '${text}'." 1>&2
        return 1
    fi
}

ckeof () {
    # Info: Check whether final EOL (end-of-line) is missing.
    # Syntax: [file-or-dir1 [file-or-dir2...]]

    typeset enforcecwd="${1:-.}" ; shift
    typeset files

    for i in "${enforcecwd}" "$@"; do
        if [ -d "$i" ] ; then
            files=$(find "$i" -type f)
        else
            files="${i}"
        fi

        while read file ; do
            #if (tail -n 1 "$i"; echo '##EOF##') | grep -q '.##EOF##$' ; then
            if [ "$(awk 'END{print FNR;}' "${file}")" != \
                "$(wc -l "${file}" | awk '{print $1}')" ]
            then
                echo "${file}"
            fi
        done <<EOF
${files}
EOF
    done
}

ckeolwin () {
    # Info: Check whether any file has windows end-of-line.
    # Syntax: [file-or-dir1 [file-or-dir2...]]

    typeset enforcecwd="${1:-.}" ; shift
    typeset files

    for i in "${enforcecwd}" "$@"; do
        if [ -d "$i" ] ; then
            files=$(find "$i" -type f)
        else
            files="${i}"
        fi

        while read file ; do
            #if (tail -n 1 "$i"; echo '##EOF##') | grep -q '.##EOF##$' ; then

            if [ $(head -1 "${file}" | tr '\r' '\n' | wc -l | awk '{print $1;}') -eq 2 ]
            then
                echo "${file}"
            fi
        done <<EOF
${files}
EOF
    done
}

dos2unix () {
    # Info: Remove CR Windows end-of-line (0x0d) from file.
    # Syntax: [file1 [file2...]]

    for i in "$@" ; do
        echo "Deleting CR chars from '${i}' (temp '${i}.u').."
        tr -d '\r' < "${i}" > "${i}.u"
        mv "${i}.u" "${i}"
    done
}

echogrep () {
    # Info: Grep echoed arguments instead of files.

    typeset re
    typeset iopt qopt vopt

    typeset oldind="$OPTIND"
    OPTIND=1
    while getopts ':iqv' opt ; do
        case "${opt}" in
        i) iopt='-i';;
        q) qopt='-q';;
        v) vopt='-v';;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    re="$1" ; shift

    egrep ${iopt} ${qopt} ${vopt} "$re" <<EOF
$(for i in "$@" ; do echo "${i}" ; done)
EOF
}

fixeof () {
    # Info: Fix and add final EOL (end-of-line) when missing.
    # Syntax: [file-or-dir1 [file-or-dir2...]]

    [ "${1}" = '-v' ] && verbose=true && shift
    typeset enforcecwd="${1:-.}" ; shift
    typeset files

    for i in "${enforcecwd}" "$@"; do
        if [ -d "${i}" ] ; then
            files=$(find "${i}" -type f)
        else
            files="${i}"
        fi

        while read file ; do
            #if (tail -n 1 "$i"; echo '##EOF##') | grep -q '.##EOF##$' ; then
            if [ "$(awk 'END{print FNR;}' "${file}")" != \
                "$(wc -l "${file}" | awk '{print $1}')" ]
            then
                echo -e '\n\c' >> "${file}"

                if ${verbose:-false} ; then
                    echo "${file}"
                fi
            fi
        done <<EOF
${files}
EOF
    done
}

getsection () {
    # Info: Picks an (old format) ini section from a file.

    typeset sectionsearch="$1"
    typeset filename="$2"

    awk '
    # Find the entry:
    /^ *\['"${sectionsearch}"'\] *$/ { found = 1; print "sectionname=" $0; }

    # Print entry content:
    found && $0 ~ /^ *[^[]/ { inbody = 1; print; }

    # Stop on next entry after printing:
    inbody && $0 ~ /^ *\[/ { exit 0; }
    ' "${filename}"
}

# ##############################################################################
