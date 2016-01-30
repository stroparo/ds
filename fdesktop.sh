# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Desktop functions

# Function m3uzer: create m3u files inside the specified directory tree.
# Syntax: {root-directory}
unset m3uzer
m3uzer () {
  if [ ! -d "${1}" ] ; then
    "Aborted because the argument is not a directory."
  fi

  cd "${1}"

  find . -type d | while read d ; do
    echo '#EXTM3U' > "${d}/$(basename "${d}").m3u"
    
    (cd "${d}" ; ls -1) | \
    egrep -i '[.]mp3|[.]flac|[.]wma|[.]ogg|[.]flv|[.]mp4' | \
    while read f ; do
      [ -f "${d}/${f}" ] || continue
      echo "#EXTINF:0,${f%.*}" >> "${d}/$(basename "${d}").m3u"
      echo "${f}" >> "${d}/$(basename "${d}").m3u"
    done

    if [ "$(cat "${d}/$(basename "${d}").m3u" | wc -l)" -gt 1 ] ; then
      echo "Generated '${d}/$(basename "${d}").m3u'"
    else
      rm -f "${d}/$(basename "${d}").m3u"
    fi
  done

  cd - >/dev/null 2>&1
}

# Function screenshot: take a screenshot of the desktop, by default after 5 seconds.
# Syntax: [secondsToWait=5]
screenshot () {
    typeset date_ymd_hms=$(date '+%Y%m%d-%H%M%S')

    sleep "${1:-5}"
    import -window root "${HOME}/screenshot-${date_ymd_hms}.png"
}
