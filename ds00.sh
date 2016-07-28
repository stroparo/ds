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
alias cdlt='cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt'
alias t='d "${TEMP_DIRECTORY}" -A'

# Environment tests
_is_aix () { [[ $(uname -a) = *[Aa][Ii][Xx]* ]] ; }
_is_cygwin () { [[ "$(uname -a)" = *[Cc]ygwin* ]] ; }
_is_debian () { [[ "$(uname -a)" = *[Db]ebian* ]] ; }
_is_linux () { [[ "$(uname -a)" = *[Ll]inux* ]] || _is_debian || _is_ubuntu ; }
_is_ubuntu () { [[ "$(uname -a)" = *[Uu]buntu* ]] ; }

# Function aliasnoext
# Purpose:
# Pick argument directories' scripts and yield corresponding aliases with no extension.
# Syntax:
# {directory}1+
unset aliasnoext
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
                if [ -x "${script}" ] ; then
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

# Function chmodshells - Sets mode for scripts inside the specified directories.
unset chmodshells
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

# Function enforcedir - Tries to create the directory and fails if not rwx.
unset enforcedir
enforcedir () {
    typeset pname=enforcedir

    for d in "$@" ; do
        mkdir -p "${d}" 2>/dev/null

        if _any_dir_not_rwx "${d}" ; then
            elog -f -n "$pname" "You do not have rwx mode for '${d}' directory."
            return 1
        fi
    done
}

unset findscripts
findscripts () {

    typeset pname=findscripts

    typeset re_scripts="perl|python|ruby|sh"

    awk 'FNR == 1 && $0 ~ /^#!.*('"${re_scripts}"') */ {
        print FILENAME;
    }' \
        $(find "$@" -type f | egrep -v '[.](git|hg|svn)')
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

# Function paralleljobs - Fires parallel processes, entries read from stdin one per line.
#   '{}' expressions in the command yield the entry for the current job.
#
# Syntax:
#   [-l {logdir}] [-n {args-per-process}] [-p {maxprocesses}] [-z {taskname}] {command}
#
# Options:
#
#   -l {logdir}
#       Defaults to $DS_ENV_LOG
#
#   -z {cmdzero}
#       Specify the task name for example when the command starts
#       with other stuff in lieu of the command, such as IFS=...
#       This is what gets put into the log filename.
#
# Example:
#   "gzip '{}'"
#
unset paralleljobs
paralleljobs () {
    typeset argcount=0
    typeset cmd cmdzero flatentry iargs icmd ilog ilogsuffix
    typeset dotee=false
    typeset haltstring='__HALT__'
    typeset logdir="${DS_ENV_LOG}"
    typeset logsuffixmulti='pno_'
    typeset maxprocs=4
    typeset n=1
    typeset pcount=0
    typeset pname='paralleljobs'
    typeset ts="$(date '+%Y%m%d%OH%OM%OS')"

    # Options:
    while getopts ':l:n:p:tz:' opt ; do
        case "${opt}" in
        l) logdir="${OPTARG}";;
        n) n="${OPTARG}";;
        p) maxprocs="${OPTARG}";;
        t) dotee=true;;
        z) cmdzero="${OPTARG}";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    cmd="${1} ; res=\$? ; echo \$(date '+%Y%m%d-%OH%OM%OS') ; echo \${res}"
    : ${cmdzero:=${1%% *}}
    setlogdir "${logdir}" || return 10

    # Enforce number type: 
    [[ ${maxprocs} = [1-9]* ]] || maxprocs=4
    [[ ${n} = [1-9]* ]] || n=1

    # Argcount fixed for n==1:
    [ "${n}" -eq 1 ] && argcount=1

    LOGS=()

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
            elog -f -n "${pname}" \
                "Invalid number of args per process in n option, must be positive."
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
        iargs="$(echo "${iargs}" | sed 's#&#\\&#g')"
        icmd="$(echo "${cmd}" | sed -e "s#[{][}]#${iargs}#g")" || return 30
        pcount=$((pcount+1))
        if [ "${n}" -gt 1 ] ; then
            ilogsuffix="${logsuffixmulti}${pcount}"
        fi
        ilog="${logdir}/${cmdzero}_${ts}_${ilogsuffix}.log"
        echo "Command: ${icmd}" > "${ilog}" || return 40

        # Wait for a vacant pool slot:
        while [ `jobs -r | wc -l` -ge ${maxprocs} ] ; do true ; done

        # elog "Subproc #${pcount} .."
        if $dotee ; then
            LOGS=(${LOGS[@]} "$ilog")
        fi
        nohup bash -c "${icmd}" >> "${ilog}" 2>&1 &
    done

    if [ "${pcount}" -gt 0 ] ; then
        elog "Finished launching a total of ${pcount} processes for this jobset."
        elog "Processing last batch of `jobs -p | wc -l` jobs.."
    fi

    if $dotee ; then
        wait || return 1
        for log in ${LOGS[@]} ; do
            echo "$(ex "$log" <<EOF
            :/{res}$/+1,$p
EOF
            )" | \
                head -n -2
        done
    fi
}

# Function pathmunge - prepend (-a causes to append) directory to PATH global.
# Syntax: [-v varname] {path}1+
unset pathmunge
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

# Function ps1enhance - make PS1 better, displaying user, host, time, $? and the
#   current directory.
unset ps1enhance
ps1enhance () {
    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
}

# Function runcommands - calls commands in the argument ( one per line), in order.
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

    mkdir -p "${logdir}" 2>/dev/null

    if [ ! -d "${logdir}" -o ! -w "${logdir}" ] ; then
        echo "FATAL: '$logdir' log dir unavailable." 1>&2
        return 10
    fi
}

# Function sourcefiles - each arg is a glob; source all glob expanded paths.
#  Tilde paths are accepted, as the expansion is yielded
#  via eval. Expanded directories are ignored.
#  Stdout is fully redirected to stderr.
unset sourcefiles
sourcefiles () {

    typeset oldind="${OPTIND}"
    typeset pname='sourcefiles'
    typeset quiet=false
    typeset tolerant=false
    typeset verbose=false

    typeset name src srcresult
    typeset nta='Non-tolerant abort.'

    # Options:
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

    if $verbose && test -n "${name}" ; then
        $quiet || elog -n "${pname}" "GROUP '${name}'"
    fi

    for globpattern in "$@" ; do

        if ! eval ls -1d ${globpattern} >/dev/null 2>&1 ; then
            $quiet || elog -s -n "${pname}" "Glob '${globpattern}' had no matches."

            if ! ${tolerant} ; then
                $quiet || elog -f -n "${name}" "${nta} Bad glob."
                return 1
            fi
            continue
        fi

        exec 4<&0

        while read src ; do
            if $verbose ; then
                $quiet || elog -n "${pname}" "=> '${src}'.."
            fi

            if [ -r "${src}" ] ; then
                . "${src}" 1>&2
            else
                $quiet || elog -w -n "${pname}" "'${src}' was not readable."
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
unset userconfirm
userconfirm () {

    typeset confirm

    echo ${BASH_VERSION:+-e} "$@" "[y/N] \c"

    read confirm

    if [[ $confirm = [yY]* ]] ; then
        return 0
    else
        return 1
    fi
}

# Function userinput - Read value to variable userinput.
unset userinput
userinput () {

    echo ${BASH_VERSION:+-e} "$@: \c"

    read userinput
}

# ##############################################################################
# Text processing functions

# Function appendunique - If string not present in file, append to it.
# Syntax: string file1 [file2 ...]
unset appendunique
appendunique () {

    typeset msgerrforfile="appendunique: ERROR for file"
    typeset failedsome=false
    typeset text="${1}" ; shift

    for f in "$@" ; do
        if ! fgrep -q "${text}" "${f}" ; then
            if ! echo "${text}" >> "${f}" ; then
                failedsome=true
                echo "${msgerrforfile} '${f}' .." 1>&2
            fi
        fi
    done

    if ${failedsome} ; then
        echo "appendunique: FATAL: Text was '${text}'." 1>&2
        return 1
    fi
}

# Function catnum - Cat files and greps the catenated content for number-only lines.
# See also: greperr
unset catnum
catnum () {
    mutail -n1 "$@" | grep '^[0-9][0-9]*$'
}

# Function ckeof - Check whether final EOL (end-of-line) is missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
unset ckeof
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
unset dos2unix
dos2unix () {
    for i in "$@" ; do
        echo "Deleting CR chars from '${i}' (temp '${i}.u').."
        tr -d '\r' < "${i}" > "${i}.u"
        mv "${i}.u" "${i}"
    done
}

# Function echogrep - grep echoed arguments instead of files.
unset echogrep
echogrep () {
    typeset iopt qopt re
    typeset oldind="$OPTIND"

    OPTIND=1
    while getopts ':iq' opt ; do
        case "${opt}" in
        i) iopt='-i';;
        q) qopt='-q';;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    re="$1" ; shift

    grep ${iopt} ${qopt} "$re" <<EOF
$(for i in "$@" ; do echo "${i}" ; done)
EOF
}

# Function echoupcase - Echoes arguments then translates to uppercase via piped tr.
unset echoupcase
echoupcase () {
    echo "$@" | tr '[[:lower:]]' '[[:upper:]]'
}

# Function fixeof - Fix and add final EOL (end-of-line) when missing.
# Syntax: [file-or-dir1 [file-or-dir2...]]
unset fixeof
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
unset getsection
getsection () {

    typeset pname=getsection
    typeset filename="$2"
    typeset sectionsearch="$1"

    awk -vsectionsearch="${sectionsearch}" '

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
unset greperr
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
    typeset oldind="${OPTIND}"
    typeset outsep
    typeset pattern
    typeset printargs
    typeset usage=\
'Syntax: printawk -F fieldsep -O outsep -p pattern {1st field} [2nd field [3rd ...]]'

    OPTIND=1
    while getopts ':F:O:p:' opt ; do
        case "${opt}" in
        F) fieldsep="${OPTARG}" ;;
        O) outsep="${OPTARG}" ;;
        p) pattern="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    [ "$#" -eq 0 ] && echo "${usage}" 1>&2 && return

    for i in "$@" ; do
        printargs="${printargs:+${printargs}, }\$${i}"
    done

    awk ${fieldsep:+-F${fieldsep}} \
        ${outsep:+-vOFS=${outsep}} \
        "${pattern}${pattern:+ }{print ${printargs};}"
}

# Function progmiss - Checks 'which' programs and prints missing programs.
unset progmiss
progmiss () {
    typeset misslist prog

    if [[ -z ${1} ]] ; then
        echo 'No-op. Must input at least one argument.'
        return
    fi

    for prog in "$@" ; do
        which "${prog}" >/dev/null 2>&1 || misslist="${misslist:+${misslist} }${prog}"
    done

    misslist="${misslist% }"

    if [[ -n ${misslist} ]] ; then
        echo "Missing binaries: ${misslist}"
        return
    fi

    return 1
}

# Function - Wrapper function for a tr call from [[:lower:]] to [[:upper:]].
unset upcase
upcase () {
    tr '[[:lower:]]' '[[:upper:]]'
}

# ##############################################################################
# Testing functions

_all_not_null () {
    for i in "$@" ; do
        [ -z "${i}" ] && return 1
    done
    return 0
}

_any_dir_not_r () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_w () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_dir_not_rwx () {
    for i in "$@" ; do
        if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_exists () {
    for i in "$@" ; do
        if [ -e "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_null () {
    for i in "$@" ; do
        if [ -z "${i}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_r () {
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -r "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

_any_not_w () {
    for i in "$@" ; do
        if [ -n "${1}" ] && [ ! -w "${1}" ] ; then
            return 0
        fi
    done
    return 1
}

# ##############################################################################
# Bootstrap calls:

if [ -n "${DS_VERBOSE}" ] ; then
    dsinfo 1>&2
fi
