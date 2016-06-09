# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# DS base objects
alias t='d "${TEMP_DIRECTORY}" -A'

# DS aliases - change directory:
alias cdbak='d "${BACKUP_DIRECTORY}" -A'
alias cde='d "${DS_ENV}" -A'
alias cdl='cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64)'
alias cdll='d "${DS_ENV_LOG}" -Art'
alias cdlgt='cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")")'
alias cdlt='cd "${DS_ENV_LOG}" && d "$(date "+%Y%m%d")" -ARrt'
alias t='d "${TEMP_DIRECTORY}" -A'

# Environment tests
_is_aix () { [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; }
_is_cygwin () { [[ "$(uname -a)" = *[Cc]ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] || _is_debian || _is_ubuntu ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }

# Function aliasnoext - pick {argument}/*sh and yield aliases without extension.
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

# Function appendto - Append to variable (arg1), the given text (arg2).
unset appendto
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
unset cyd 2>/dev/null
cyd () {
    _is_cygwin && cd /cygdrive/"${1:-c}" && ls -AFhl 1>&2
}

# Function ckenv - check number of arguments and sets hasgnu ("GNU is not Unix").
# Syntax: {min-args} [max-args=min-args]
unset ckenv
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
unset d
d () {
    dir="${1}"
    shift

    cd "${dir}" || return 1
    pwd 1>&2
    ls -Fl "$@" 1>&2
}

# Function echodots - Echoes dots between 200s or number of seconds in arg1.
unset echodots
echodots () {
    trap return SIGPIPE
    while sleep "${1:-200}" ; do
        if [ -n "${BASH_VERSION}" ] ; then
            echo -n '.' 1>&2
        elif [[ ${SHELL} = *ksh ]] ; then
            echo '.\c' 1>&2
        else
            echo '.'
        fi
    done
}

# Function elog - echoes a string to standard error.
unset elog
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

# Function getnow - setup NOW* and TODAY* environment variables.
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

# Function paralleljobs - Fires parallel processes, entries read from stdin
#  replace {} expressions in the command.
# Syntax: [-n {args-per-process}] [-p maxprocesses] {command}
# Remark: 
# Example: "gzip '{}'"
unset paralleljobs
paralleljobs () {
    typeset argcount=0
    typeset cmd cmdzero flatentry iargs icmd ilog ilogsuffix
    typeset haltstring='__HALT__'
    typeset logdir="${DS_ENV_LOG}"
    typeset logsuffixmulti='pno_'
    typeset maxprocs=4
    typeset n=1
    typeset pcount=0
    typeset pname='paralleljobs'
    typeset ts="$(date '+%Y%m%d%OH%OM%OS')"

    # Options:
    while getopts ':l:n:p:' opt ; do
        case "${opt}" in
        l) logdir="${OPTARG}";;
        n) n="${OPTARG}";;
        p) maxprocs="${OPTARG}";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    cmd="${1} ; res=\$? ; echo \$(date '+%Y%m%d-%OH%OM%OS') ; echo \${res}"
    cmdzero="${1%% *}"
    setlogdir "${logdir}" || return 10

    # Enforce number type: 
    [[ ${maxprocs} = [1-9]* ]] || maxprocs=4
    [[ ${n} = [1-9]* ]] || n=1

    # Argcount fixed for n==1:
    [ "${n}" -eq 1 ] && argcount=1

    while read entry ; do
        [ -z "${entry}" ] && continue

        # Argument list:
        if [ "${n}" -eq 1 ] ; then
            flatentry="$(echo "${entry}" | sed -e 's#/#_#g')"
            ilogsuffix="${flatentry}"
            iargs="'${entry}'"
        elif [ "${n}" -gt 1 ] ; then
            [ "${argcount}" -eq "${n}" ] && argcount=0

            if [ "${entry}" != "${haltstring}" ] ; then
                argcount=$((argcount+1))

                if [ "${argcount}" -eq 1 ] ; then
                    iargs="'${entry}'"
                else
                    iargs="${iargs} '${entry}'"
                fi

                [ "${argcount}" -lt "${n}" ] && continue
            fi
        else
            elog -f -n "${pname}" "Invalid number of args per process in n option, must be positive."
            return 20
        fi

        # Halting control is best when processing multi-args at a time (n > 1):        
        if [ "${entry}" = "${haltstring}" ] ; then
            if [ "${argcount:-0}" -eq 0 ] ; then
                elog -w "Halt string found but no arguments pending,"
                elog -w " ie either the input was empty or the number"
                elog -w " of entries was a multiple of n.."
                break
            fi

            elog -w "Halt string found; calling last job of this set.."
        fi

        # Prep command and its log filename:
        icmd="$(echo "${cmd}" | sed -e "s#[{][}]#${iargs}#g")" || return 30
        pcount=$((pcount+1))
        if [ "${n}" -gt 1 ] ; then
            ilogsuffix="${logsuffixmulti}${pcount}"
        fi
        ilog="${logdir}/${cmdzero}_${ts}_${ilogsuffix}.log"
        echo "Command: ${icmd}" > "${ilog}" || return 40

        # Wait for a vacant pool slot:
        while [ `jobs -r | wc -l` -ge ${maxprocs} ] ; do true ; done

        # elog "bash -c \"${icmd}\" >> \"${ilog}\" 2>&1 &" 2>&1 | tee -a "${logdir}"/debug-paralleljobs.log
        # elog "Subproc #${pcount} .."
        nohup bash -c "${icmd}" >> "${ilog}" 2>&1 &
    done

    if [ "${pcount}" -gt 0 ] ; then
        elog "Finished launching a total of ${pcount} processes for this jobset."
        elog "Processing last batch of `jobs -p | wc -l` jobs.."
    fi
}

# Function pathmunge - prepend (-a causes to append) directory to PATH global.
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

# Function pgr - pgrep emulator.
# Syntax: [egrep-pattern]
unset pgr
pgr () {
    typeset options

    # Options:
    while getopts ':' opt ; do
        options="${options} -${opt} ${OPTARG:-'${OPTARG}'}"
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    ps -ef | egrep -i ${options} "$@" | egrep -v "grep.*(${1})"
}

# Function ps1enhance - make PS1 better, displaying user, host, time, $? and the current directory.
unset ps1enhance
ps1enhance () {
    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
}

# Function runcommands - calls commands in the argument (most be one per line), in order.
unset runcommands
runcommands () {
    typeset commandlist="${1}"
    typeset nextcommand

    while read nextcommand ; do
        eval "${nextcommand}"
done <<EOF
${commandlist}
EOF
}

# Function setlogdir - create and check log directory.
# Syntax: {log-directory}
unset setlogdir
setlogdir () {
    typeset logdir="${1}"
    typeset pname='setlogdir'

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        elog -f -n "${pname}" "'$logdir' log dir unavailable."
        return 10
    fi
}

# Function sourcefiles - each arg is a glob; source all glob expanded paths.
#  Tilde paths are accepted, as the expansion is yielded
#  via eval. Expanded directories are ignored.
#  Stdout is fully redirected to stderr.
unset sourcefiles
sourcefiles () {
    typeset name src srcresult tolerant verbose
    typeset nta='Non-tolerant abort.'
    typeset pname='sourcefiles'

    # Options:
    while getopts ':n:tv' opt ; do
        case "${opt}" in
        n) name="${OPTARG}";;
        t) tolerant=true;;
        v) verbose=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    [ -n "${verbose}" -a -n "${name}" ] && elog -n "${pname}" "GROUP '${name}'"

    for globpattern in "$@" ; do

        if ! eval ls -1d ${globpattern} >/dev/null 2>&1 ; then
            elog -s -n "${pname}" "Glob '${globpattern}' had no matches."
            [ -z "${tolerant}" ] && elog -f -n "${name}" "${nta} Bad glob." && return 1
            continue
        fi

        exec 4<&0

        while read src ; do
            [ -n "${verbose}" ] && elog -n "${pname}" "=> '${src}'.."

            if [ -r "${src}" ] ; then
                . "${src}" 1>&2
            else
                elog -w -n "${pname}" "'${src}' was not readable."
                false
            fi
            srcresult=$?

            if [ "${srcresult}" -ne 0 ] ; then
                [ -z "${tolerant}" ] \
                && elog -f -n "${pname}" "${nta} Sourcing '${src}'." \
                && return 1

                elog -w -n "${pname}" "Tolerant fail for '${src}'."
            else
                if [ -n "${verbose}" ] ; then
                    elog -n "${pname}" "=> '${src}' completed successfully."
                fi
            fi
        done <<EOF
$(eval ls -1d ${globpattern} 2>/dev/null)
EOF
    done
    if [ -n "${verbose}" -a -n "${name}" ] ; then
        elog -n "${pname}" "GROUP COMPLETE."
    fi
}

# Function topu - top user processes, or topas when working in AIX.
unset topu
topu () {
    if _is_aix ; then
        topas -U "${USER}" -P
    else
        top -U "${UID:-$(id -u)}"
    fi
}

# ##############################################################################
# Text processing functions

# Function appendunique - If string not present in file, append to it.
# Syntax: string filename
unset appendunique
appendunique () {
    if touch "${2}" && [ -w "${2}" ]; then
        fgrep -q "${1}" "${2}" || echo "${1}" >> "${2}"
    else
        echo "Cannot write to '${2}'. Aborted." 1>&2
        return 1
    fi
}

# Function catnum - Cat files and greps the catenated content for number-only lines.
# See also: greperr
unset catnum
catnum () {
    mutail -n1 "$@" | grep '^[0-9][0-9]*$'
}

# Function ckwineol - check whether any file has windows end-of-line.
# Syntax: [file-or-dir1 [file-or-dir2...]]
unset ckwineol
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
            
            if [ $(head -1 "${file}" | tr '\r' '\n' | wc -l | awk '{print $1;}') -eq 2 ] ; then
                echo "${file}"
            fi
        done <<EOF
${files}
EOF
    done
}

# Function dos2unix - remove CR Windows end-of-line (0x0d) from file.
# Syntax: [file1 [file2...]]
unset dos2unix
dos2unix () {
    for i in "$@" ; do
        echo "Deleting CR chars from '${i}' (temp '${i}.u').."
        tr -d '\r' < "${i}" > "${i}.u"
        mv "${i}.u" "${i}"
    done
}

# Function eofck - Check whether final EOL (end-of-line) is missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
unset eofck
eofck () {
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
            if [ "$(awk 'END{print FNR;}' "${file}")" != "$(wc -l "${file}" | awk '{print $1}')" ] ; then
                echo "${file}"
            fi
        done <<EOF
${files}
EOF
    done
}

# Function eoffix - Fix and add final EOL (end-of-line) when missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
unset eoffix
eoffix () {
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
            if [ "$(awk 'END{print FNR;}' "${file}")" != "$(wc -l "${file}" | awk '{print $1}')" ] ; then
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

# Function gettimes: get log times for every *.log file inside the current directory tree.
unset gettimes
gettimes () {
    for i in $(find . -name '*.log') ; do
        # Job name:
        echo $(basename ${i})

        # Obtain time in seconds:
        cat ${i} | awk -F'[: ]+' '
            /^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ {
                if ( ! first_consumed ) {
                    first = ($1 * 3600) + ($2 * 60) + $3
                    first_consumed = "True";
                }
                last = ($1 * 3600) + ($2 * 60) + $3
            }
            END { time = last - first; print time, "seconds"; }
        '
    done
}

# Function greperr - Checks files' last line is a sole zero.
# Remark: Common case scenario, an exit status $? logged last by a command.
unset greperr
greperr () {
    for f in "$@" ; do
        echo "==> ${f} <=="
        tail -n 1 "${f}" | grep -v '[[:space:]]*0$'
    done
}

# Function mucat - cat multiple files.
# Syntax: mucat file1[ file2[ file3 ...]]
unset mucat
mucat () {
    typeset first=true

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        cat "${f}"

        first=false
    done
}

# Function mutail - tail multiple files.
# Syntax: mutail [-n lines] file1[ file2[ file3 ...]]
unset mutail
mutail () {
    typeset first=true
    typeset lines=10

    while getopts ':n:' opt ; do
        case "${opt}" in
        n)
            lines="${OPTARG}"
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        tail -n ${lines:-10} "${f}"

        first=false
    done
}

# Function printawk - Prints fields as read by awk.
unset printawk
printawk () {
    typeset fieldsep
    typeset outsep
    typeset pattern
    typeset printargs

    while getopts ':F:O:p:' opt ; do
        case "${opt}" in
        F) fieldsep="${OPTARG}" ;;
        O) outsep="${OPTARG}" ;;
        p) pattern="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    printargs="\$${1}"
    shift

    for i in "$@" ; do
        printargs="${printargs}, \$${i}"
    done

    awk ${fieldsep:+-F${fieldsep}} \
        ${outsep:+-vOFS=${outsep}} \
        "${pattern}${pattern:+ }{print ${printargs};}"
}

# ##############################################################################
# Testing functions

_all_not_null () {
    for i in "$@" ; do
        [ -z "${i}" ] && return 1
    done
    return 0
}

_any_dir_not_w () {
    for i in "$@" ; do
        [ ! -d "${1}" -o ! -w "${1}" ] && return 0
    done
    return 1
}

_any_exists () {
    for i in "$@" ; do
        [ -e "${1}" ] && return 0
    done
    return 1
}

_any_null () {
    for i in "$@" ; do
        [ -z "${i}" ] && return 0
    done
    return 1
}

_any_not_w () {
    for i in "$@" ; do
        [ -n "${1}" -a ! -w "${1}" ] && return 0
    done
    return 1
}

# ##############################################################################
# Bootstrap calls:

[ -n "${DS_VERBOSE}" ] && dsinfo 1>&2

sourcefiles "${DS_HOME}/aliases*sh"
