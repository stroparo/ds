# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################

appendunique () {
    # Info: If string not present in file, append to it.
    # Syntax: string file1 [file2 ...]

    typeset msgerrforfile="appendunique: ERROR for file"
    typeset failedsome=false
    typeset text="${1}" ; shift

    if [ -z "$text" ] ; then return ; fi

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

