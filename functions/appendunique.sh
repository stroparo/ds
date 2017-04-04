appendunique () {
    # Syntax: string file1 [file2 ...]
    [ -z "$1" ] && return 0
    typeset fail=0
    typeset text="${1}" ; shift
    for f in "$@" ; do
        [ ! -e "$f" ] && fail=1 && echo "ERROR '${f}' does not exist" 1>&2 && continue
        if ! fgrep -q "${text}" "${f}" ; then
            ! echo "${text}" >> "${f}" && fail=1 && echo "ERROR appending '${f}'" 1>&2
        fi
    done
    return ${fail}
}

