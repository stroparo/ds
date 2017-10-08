#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

installdropbox () {
    [[ "$(uname -a)" = *[Ll]inux* ]] || return
    [ -e ~/.dropbox-dist/dropboxd ] && return

    echo '==> Installing dropbox...' 1>&2

    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | \
        tar xzf -

    env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &
}

installdropbox "$@"
