appendunique () {
    # Syntax: string file1 [file2 ...]
    [ "$1" = '-n' ] && shift && typeset newline=true
    [ -z "$1" ] && return 0
    typeset fail=0
    typeset text="${1}" ; shift
    for f in "$@" ; do
        if [ ! -e "$f" ] ; then
            fail=1
            echo "ERROR '${f}' does not exist" 1>&2
            continue
        fi
        if ! fgrep -q "$text" "$f" ; then
            ${newline:-false} && echo ${BASH_VERSION:+-e} '\n' >> "$f"
            if ! echo "$text" >> "$f" ; then
                fail=1
                echo "ERROR appending '$f'" 1>&2
            fi
        fi
    done
    return ${fail}
}

