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
alias cdbak='d "${BACKUP_DIRECTORY}" -A'
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

# Retrofit:
paralleljobs () { dsp "$@" ; }

# ##############################################################################
# Testing routines

_is_aix () { [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; }
_is_cygwin () { [[ "$(uname -a)" = *[Cc]ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] || _is_debian || _is_ubuntu ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }

_all_not_null () {
    for i in "$@" ; do
        [ -z "${i}" ] && return 1
    done
    return 0
}

_any_dir_not_r () {
    # Tests if any of the directory arguments are not readable.
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_w () {
    # Tests if any of the directory arguments are not writable.
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_rwx () {
    # Tests if any of the directory arguments are neither readable nor w nor x.
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_exists () {
    # Tests if any of the arguments exist.
    for i in "$@" ; do
        if [ -e "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_null () {
    # Tests if any of the arguments is null.
    for i in "$@" ; do
        if [ -z "${i}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_r () {
    # Tests if any of the arguments is not readable.
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_w () {
    # Tests if any of the arguments is not writable.
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

# ##############################################################################
# Filesystem

# Function chmodshells - Sets mode for scripts inside the specified directories.
chmodshells () {
    typeset oldind="$OPTIND"

    typeset addaliases=false
    typeset addpaths=false
    typeset mode='u+rwx'
    typeset verbose

    # Options:
    OPTIND=1
    while getopts ':am:pv' opt ; do
        case "${opt}" in
        a) addaliases=true ;;
        m) mode="${OPTARG}" ;;
        p) addpaths=true ;;
        v) verbose='-v' ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for dir in "$@" ; do
        if ! _any_dir_not_w "${dir}" ; then
            # [[ -n $ZSH_VERSION ]] && set -o shwordsplit
            chmod ${verbose} "${mode}" $(findscripts "${dir}")
            # [[ -n $ZSH_VERSION ]] && set +o shwordsplit
        fi
    done

    if ${addpaths}; then
        pathmunge -x "$@"
    fi

    if ${addaliases}; then
        aliasnoext "$@"
    fi
}

# Function enforcedir - Tries to create the directory and fails if not rwx.
enforcedir () {
    mkdir -p "$@" 2>/dev/null
    if _any_dir_not_rwx "$@" ; then return 1 ; fi
}

# Function findscripts - Finds script type files in root dirs passed as arguments.
findscripts () {
    typeset re_shells='perl|python|ruby|sh'
    awk 'FNR == 1 && $0 ~ /^#!.*('"$re_shells"') */ { print FILENAME; }' \
        $(find "$@" -type f | egrep -v '[.](git|hg|svn)')
}

# ##############################################################################
# Shell functions

# Function aliasnoext
# Purpose:
# Pick argument directories' scripts and yield corresponding aliases with no extension.
# Syntax:
# {directory}1+
aliasnoext () {

    typeset oldind="${OPTIND}"
    typeset verbose=false

    OPTIND=1
    while getopts ':v' opt ; do
        case "${opt}" in
        v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for dir in "$@" ; do
        if ! _any_dir_not_w "${dir}" ; then
            while read script ; do
                if [[ $script = *.* ]] && [ -x "${script}" ] ; then
                    aliasname="${script##*/}"
                    aliasname="${aliasname%%.*}"
                    eval unalias "${aliasname}" 2>/dev/null
                    eval alias "${aliasname}=${script}"
                    $verbose && eval type "${aliasname}"
                fi
            done <<EOF
$(findscripts "${dir}")
EOF
        fi
    done
}

# Function appendto - Append to variable (arg1), the given text (arg2).
appendto () {
    if [ -z "$(eval "echo \"\$${1}\"")" ] ; then
        eval "${1}=\"${2}\""
    else
        eval "${1}=\"\$${1}
${2}\""
    fi
}

# Function cyd - cd to the disk drive letter argument; fails if not in cygwin.
# Syntax: cyd {a|b|c|d|e|f|...}
cyd () {
    _is_cygwin && cd /cygdrive/"${1:-c}" && ls -AFhl 1>&2
}

# Function ckenv - check number of arguments and sets hasgnu ("GNU is not Unix").
# Syntax: {min-args} [max-args=min-args]
ckenv () {
    typeset args_slice_min="${1:-0}"
    typeset args_slice_max="${2:-0}"
    shift 2

    if ! [ "${#}" -ge "${args_slice_min}" -a \
           "${#}" -le "${args_slice_max}" ] ; then
        echo "Bad arguments:" "$@" 1>&2
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
d () {
    dir="${1}"
    shift

    cd "${dir}" || return 1
    pwd 1>&2
    ls -Fl "$@" 1>&2

    if which git >/dev/null 2>&1 && [ -e "${PWD}/.git" ]; then
        git status -s
    fi
}

# Function echodots - Echoes dots between 200s or number of seconds in arg1.
echodots () {
    trap return SIGPIPE
    while sleep "${1:-4}" ; do
        if [ -n "${BASH_VERSION}" ] ; then
            echo -n '.' 1>&2
        elif [[ ${SHELL} = *[kz]sh ]] ; then
            echo '.\c' 1>&2
        else
            echo '.'
        fi
    done
}

# Function getnow - setup NOW* and TODAY* environment variables.
getnow () {
    export NOW_HMS="$(date '+%OH%OM%OS')"
    export NOW_YMDHM="$(date '+%Y%m%d%OH%OM')"
    export NOW_YMDHMS="$(date '+%Y%m%d%OH%OM%OS')"
    export TODAY="$(date '+%Y%m%d')"
    export TODAY_ISO="$(date '+%Y-%m-%d')"
}

# Function loop - pass a command to be executed every secs seconds.
# Syntax: [-d secs] command
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

# Function pathmunge - prepend (-a causes to append) directory to PATH global.
# Syntax: [-v varname] [-x] {path}1+
# Remark:
#   -x causes variable to be exported.
pathmunge () {
    typeset oldind="${OPTIND}"

    typeset doexport=false
    typeset mungeafter=false
    typeset varname=PATH
    typeset mgdpath mgdstring previous

    OPTIND=1
    while getopts ':av:x' opt ; do
        case "${opt}" in
        a) mungeafter=true ;;
        v) varname="${OPTARG}" ;;
        x) doexport=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    for i in "$@" ; do
        mgdpath="$(eval echo "\"${i}\"")"
        previous="$(eval echo '"${'"${varname}"'}"')"

        if ${mungeafter} ; then
            mgdstring="${previous}${previous:+:}${mgdpath}"
        else
            mgdstring="${mgdpath}${previous:+:}${previous}"
        fi

        eval "${varname}='${mgdstring}'"
    done

    if ${doexport} ; then eval export "${varname}" ; fi
}

# Function ps1enhance - make PS1 better, displaying user, host, time, $? and the
#   current directory.
ps1enhance () {
    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
}

# Function setlogdir - create and check log directory.
# Syntax: {log-directory}
setlogdir () {
    typeset logdir="${1}"

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        echo "$fatal '$logdir' log dir unavailable." 1>&2
        return 10
    fi
}

# Function sourcefiles - each arg is a glob; source all glob expanded paths.
#  Tilde paths are accepted, as the expansion is yielded
#  via eval. Expanded directories are ignored.
#  Stdout is fully redirected to stderr.
sourcefiles () {

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

        srcs="$(eval ls -1d ${globpattern})"

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
$(eval ls -1d ${globpattern} 2>/dev/null)
EOF
    done
    if $verbose && test -n "${name}" ; then
        elog -n "${pname}" "GROUP COMPLETE."
    fi
}

# Function userconfirm - Ask a question and yield success if user responded [yY]*
userconfirm () {
    typeset confirm
    typeset result=1
    echo ${BASH_VERSION:+-e} "$@" "[y/N] \c"
    read confirm
    if [[ $confirm = [yY]* ]] ; then return 0 ; fi
    return 1
}

# Function userinput - Read value to variable userinput.
userinput () {

    echo ${BASH_VERSION:+-e} "$@: \c"

    read userinput
}


# ##############################################################################
# Text processing functions

catnum () { mutail -n1 "$@" | grep '^[0-9][0-9]*$' ; } # TODO rename to tailnum
echoupcase () { echo "$@" | tr '[[:lower:]]' '[[:upper:]]' ; }
locase () { tr '[[:upper:]]' '[[:lower:]]' ; }
upcase () { tr '[[:lower:]]' '[[:upper:]]' ; }

# Function appendunique - If string not present in file, append to it.
# Syntax: string file1 [file2 ...]
appendunique () {

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

# Function ckeof - Check whether final EOL (end-of-line) is missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
ckeof () {
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

# Function ckwineol - check whether any file has windows end-of-line.
# Syntax: [file-or-dir1 [file-or-dir2...]]
ckeolwin () {
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

# Function dos2unix - remove CR Windows end-of-line (0x0d) from file.
# Syntax: [file1 [file2...]]
dos2unix () {
    for i in "$@" ; do
        echo "Deleting CR chars from '${i}' (temp '${i}.u').."
        tr -d '\r' < "${i}" > "${i}.u"
        mv "${i}.u" "${i}"
    done
}

# Function echogrep - grep echoed arguments instead of files.
echogrep () {
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

# Function elog - echoes a string to standard error.
elog () {

    typeset msgtype="INFO"
    typeset pname
    typeset verbosecondition

    # Options:
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
    shift $((OPTIND - 1)) ; OPTIND=1

    if [ -z "${verbosecondition}" -o -n "${DS_VERBOSE}" ] ; then
        echo "${pname:+${pname}:}${msgtype:+${msgtype}:}" "$@" 1>&2
    fi
}

# Function fixeof - Fix and add final EOL (end-of-line) when missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
fixeof () {
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

# Function getsection
# Purpose:
#   Picks up a section from a text file, sections being formatted like old ini files.
getsection () {
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

# Function greperr - Checks files' last line is a sole zero.
# Remark: Common case scenario, an exit status $? logged last by a command.
greperr () {
    for f in "$@" ; do
        if tail -n 1 "${f}" | grep -qv '[[:space:]]*0$' ; then
            echo "==> ${f} <=="
            tail -n 1 "${f}" | grep -v '[[:space:]]*0$'
        fi
    done
}

# Function mucat - cat multiple files.
# Syntax: mucat file1[ file2[ file3 ...]]
mucat () {
    typeset first=true

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        cat "${f}"

        first=false
    done
}

mutail () {

    typeset usage="Function mutail - tail multiple files.
Syntax: mutail [-n lines] file1[ file2[ file3 ...]]
"
    typeset first=true
    typeset lines=10

    while getopts ':hn:' opt ; do
        case "${opt}" in
            h) echo "$usage" ; return ;;
            n)
                lines="${OPTARG}"
                ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <==" 1>&2
        tail -n ${lines:-10} "${f}"

        first=false
    done
}

printawk () {

    typeset fieldsep
    typeset outsep
    typeset pattern
    typeset printargs
    typeset usage="Function printawk - Prints fields as read by awk
Syntax: printawk -F fieldsep -O outsep -p pattern {1st field} [2nd field [3rd ...]]
"

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':F:hO:p:' opt ; do
        case "${opt}" in
        F) fieldsep="${OPTARG}" ;;
        h) echo "${usage}" ; return ;;
        O) outsep="${OPTARG}" ;;
        p) pattern="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for i in "$@" ; do
        printargs="${printargs:+${printargs}, }\$${i}"
    done

    awk ${fieldsep:+-F${fieldsep}} \
        ${outsep:+-vOFS=${outsep}} \
        "${pattern}${pattern:+ }{print ${printargs};}"
}

# ##############################################################################
