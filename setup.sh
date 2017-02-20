#!/usr/bin/env sh

DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'

dsget () {
    rm -rf "$HOME/.ds" > /dev/null 1>&2
    wget 'https://github.com/stroparo/ds/archive/master.zip' -O "$HOME/.ds.zip" && \
        unzip "$HOME/.ds.zip" -d "$HOME" && \
        mv "$HOME/ds-master" "$HOME/.ds"
}

dsget || exit $?

. "$HOME/.ds/ds.sh" "$HOME/.ds" >/dev/null 2>&1

if [ -n "${DS_LOADED}" ] ; then
    appendunique "$DS_LOAD_CODE" "$HOME/.bashrc"
    appendunique "$DS_LOAD_CODE" "$HOME/.zshrc"
    echo "INFO: Installed. Start a new terminal session." 1>&2
else
    echo "FATAL: ds not loaded." 1>&2
    exit 99
fi

