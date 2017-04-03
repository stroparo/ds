# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

haltsafe () {
    # Info: halts only if any truecrypt is unmounted correctly.

    typeset tcdismounted=true

    if which truecrypt >/dev/null 2>&1 && \
        truecrypt -t -l && \
        ! truecrypt -d
    then
        tcdismounted=false
    fi

    if ${tcdismounted:-false} ; then
        sudo shutdown -h now
    fi
}

