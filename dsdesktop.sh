# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Desktop routines

cbf () { cb < "$1"; }
cbssh () { cb < "${HOME}/.ssh/id_rsa.pub" }

# Function getmp3 - Extracts argument file mp3 to arg.mp3 via avconv utility.
unset getmp3
getmp3 () {
    typeset oldind="$OPTIND"
    typeset removal

    OPTIND=1
    while getopts ':r' opt ; do
        case "${opt}" in
        r) removal=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    for i in "$@" ; do
        mp3filename="${i%.*}".mp3

        if [ -f "${i}" ] && [ ! -e "${mp3filename}" ] ; then
            if avconv -i "${i}" -threads 3 -acodec libmp3lame -b 128k -vn -f mp3 \
                "${mp3filename}" \
            && [ -n "${removal}" ]
            then
                rm -f "${i}"
            fi
        fi
    done
}

# Function m3uzer - create m3u files inside the specified directory tree.
# Syntax: {root-directory:-.}
unset m3uzer
m3uzer () {
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

# Function screenshot: take a screenshot of the desktop, by default after 5 seconds.
# Syntax: [secondsToWait=5]
screenshot () {
    typeset date_ymd_hms=$(date '+%Y%m%d-%H%M%S')

    sleep "${1:-5}"
    import -window root "${HOME}/screenshot-${date_ymd_hms}.png"
}

# ##############################################################################
