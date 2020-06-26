#!/usr/bin/env bash

# Author: Cristian Stroparo

# Select videos by removing those which mplayer exited error (according to you pressing Q vs Esc).

# Params:
export FILES="$(find . -type f | egrep -i '[.](avi|flv|mov|mp4|mkv|mpeg|mpg|wmv)$')"
skipto=1
movcount=0
movtotal="$(echo "$FILES" | sort | wc -l | awk '{print $1;}')"

# Options:
while getopts ':fs:' opt ; do
    case "${opt}" in
    f) mplayerfs='-fs' ;;
    s) skipto="${OPTARG}" ;;
    esac
done

# Main:
IFS='
' for i in ${FILES} ; do
    movcount="$((movcount + 1))"

    [[ "${movcount}" -lt "${skipto}" ]] && continue
    printf "%4s of %s:%s:%s\n" "${movcount}" "${movtotal}" "$(ls -lh "${i}" | awk '{print $5;}')" "$(echo ${i})"

    mplayer -quiet ${mplayerfs} "$i" 2>/dev/null | grep -q '(End of file)'
    [ "$?" -eq 0 ] && rm -f "${i}" && echo 'REMOVED' 1>&2

done

