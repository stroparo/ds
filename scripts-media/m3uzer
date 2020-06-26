#!/usr/bin/env bash
# Cristian Stroparo's custom routine

m3uzer () {
    # Info: Create m3u files inside the specified directory tree.
    # Syntax: {root-directory:-.}

    typeset m3ufile mediafile
    typeset rootdir="$(cd "${1:-.}" ; echo "${PWD}")"

    if [ ! -d "${rootdir}" ] ; then
        echo "Aborted because the argument is not a directory." 1>&2
        return 1
    fi

    while read d ; do
        m3ufile="${d}/${d##*/}.m3u"

        echo '#EXTM3U' > "${m3ufile}"

        while read f ; do
            [ -f "${f}" ] || continue
            mediafile="${f##*/}"
            echo "#EXTINF:0,${mediafile%.*}" >> "${m3ufile}"
            echo "${mediafile}" >> "${m3ufile}"
        done <<EOF
$(ls -1d "${d}"/* | egrep -i '[.](mp[34]|flac|ogg|m4a|wm[av]|avi|flv|mkv)')
EOF
        if [ "$(cat "${m3ufile}" | wc -l)" -gt 1 ] ; then
            echo "Generated '${m3ufile}'"
        else
            rm -f "${m3ufile}"
        fi
    done <<EOF
$(find -H "${rootdir}" -type d)
EOF
}

m3uzer "$@"
