# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Text processing routines

# Oneliners
catnum () { mutail -n1 "$@" | grep '^[0-9][0-9]*$' ; } # TODO rename to tailnum

# Case conversion
lowerecho () { echo "$@" | tr '[[:upper:]]' '[[:lower:]]' ; }
upperecho () { echo "$@" | tr '[[:lower:]]' '[[:upper:]]' ; }
lowertr () { tr '[[:upper:]]' '[[:lower:]]' ; }
uppertr () { tr '[[:lower:]]' '[[:upper:]]' ; }
lowervar () { eval "$1=\"\$(echo \"\$$1\" | tr '[[:upper:]]' '[[:lower:]]')\"" ; }
uppervar () { eval "$1=\"\$(echo \"\$$1\" | tr '[[:lower:]]' '[[:upper:]]')\"" ; }

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

    typeset re text
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
    text="$(for i in "$@" ; do echo "${i}" ; done)"

    if [ -z "$text" ] ; then return ; fi

    egrep ${iopt} ${qopt} ${vopt} "$re" <<EOF
${text}
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
