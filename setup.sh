#!/usr/bin/env sh

DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'

dsget () {
    rm -rf "$HOME/.ds" > /dev/null 1>&2
    wget 'https://github.com/stroparo/ds/archive/master.zip' -O "$HOME/.ds.zip" && \
        unzip "$HOME/.ds.zip" -d "$HOME" && \
        mv "$HOME/ds-master" "$HOME/.ds"
}

dsget || exit $?

if . "$HOME/.ds/ds.sh" "$HOME/.ds" 1>&2 && [ -z "${DS_LOADED}" ] ; then
    [ -e "$HOME/.bashrc" ]  && appendunique "DS_LOAD_CODE" "$HOME/.bashrc"
    [ -e "$HOME/.zshrc" ]   && appendunique "DS_LOAD_CODE" "$HOME/.zshrc"
else
    exit 99
fi

