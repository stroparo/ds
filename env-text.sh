# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

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
        tail -n 1 "${f}" | grep -v '^0$'
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

