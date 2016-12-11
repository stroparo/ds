# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

getmp3 () {
    # Info:  Extracts argument file's audio to {argument}.mp3 via avconv utility.

    typeset removal

    typeset oldind="$OPTIND"
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
