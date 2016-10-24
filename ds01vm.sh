# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Virtualbox

# Function mountvboxsf - Mount virtualbox shared folder.
# Syntax: path-to-dir (sharing will be named as its basename)
unset mountvboxsf
mountvboxsf () {

    [ -n "${1}" ] || return 1
    [ -d "${1}" ] || sudo mkdir "${1}"

    sudo mount -t vboxsf -o rw,uid="${USER}",gid="$(id -gn)" "$(basename ${1})" "${1}"

    if [ "$?" -eq 0 ] ; then
        cd "${1}"
        pwd
        ls -FlA
    fi
}

# ##############################################################################

