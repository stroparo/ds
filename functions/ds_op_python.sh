# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Python ops routines

addpystartup () {
    # Info: Add default .pystartup to home folder.
    # Rmk: No effect if file already exists.

    if [ -e ~/.pystartup ] ; then
        echo 'Nothing done because there is a ~/.pystartup file already.' 1>&2
        return
    fi

    cat > ~/.pystartup <<EOF
# Add auto-completion and a stored history file of commands to your Python
# interactive interpreter. Requires Python 2.0+, readline. Autocomplete is
# bound to the Esc key by default (you can change it - see readline docs).
#
# Store the file in ~/.pystartup, and set an environment variable to point
# to it: "export PYTHONSTARTUP=/home/user/.pystartup" in bash.
#
# Note that PYTHONSTARTUP does *not* expand "~", so you have to put in the
# full path to your home directory.
import atexit
import os
import readline
import rlcompleter

readline.parse_and_bind('tab: complete')

historyPath = os.path.expanduser("~/.pyhistory")

def save_history(historyPath=historyPath):
    import readline
    readline.write_history_file(historyPath)

if os.path.exists(historyPath):
    readline.read_history_file(historyPath)

atexit.register(save_history)
del os, atexit, readline, rlcompleter, save_history, historyPath
EOF

}

pipinstall () {

    pip --version > /dev/null || return $?

    for p in $(cat "$@") ; do
        pip install ${p}
    done
}

# ##############################################################################
