#!/usr/bin/env sh

INSTALL_DIR=${1:-$HOME/.ds}
DS_LOAD_CODE='[ -r "${HOME}/.ds/ds.sh" ] && source "${HOME}/.ds/ds.sh" "${HOME}/.ds" 1>&2'

dsget () {
    rm -rf "${INSTALL_DIR}" > /dev/null 1>&2
    wget 'https://github.com/stroparo/ds/archive/master.zip' -O "${INSTALL_DIR}.zip" && \
        unzip "${INSTALL_DIR}.zip" -d "$HOME" && \
        mv "$HOME/ds-master" "${INSTALL_DIR}"
}

dsget || exit $?

. "${INSTALL_DIR}/ds.sh" "${INSTALL_DIR}" >/dev/null 2>&1

if [ -n "${DS_LOADED}" ] ; then
    appendunique "$DS_LOAD_CODE" "$HOME/.bashrc"
    appendunique "$DS_LOAD_CODE" "$HOME/.zshrc"
    echo "INFO: DS installed." 1>&2
else
    echo "FATAL: DS not loaded." 1>&2
    exit 99
fi

