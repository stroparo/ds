# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops functions

# Service script wrapper functions:
cthttpd () { sudo "/etc/init.d/apache${2:-2}"  "${1:-restart}" ; }
ctlamp ()  { sudo "${LAMPHOME}/ctlscript.sh"   "${1:-restart}" ; }
ctpg ()    { sudo "/etc/init.d/postgresql${2}" "${1:-restart}" ; }

# Function drop_caches_3: drop I/O caches etcetera TODO review this text.
unset drop_caches_3
drop_caches_3 () {
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}

# Function makeat - run configure, make & makeinstall for custom dir/prefix.
# Default directory will be ~/opt/root
unset makeat
makeat () {

    mkdir "${1:-${HOME}/opt/root}" 2> /dev/null || return
    ./configure --prefix="${1:-${HOME}/opt/root}" && \
    make && \
    make install
  
    echo "Exit status: ""$?"
}

# Function screenb - run a bash shell in a screen session.
# Syntax: [sessionname]
unset screenb
screenb () {
    screen -S "${1:-screenbash}" bash
}

# Function screenk - run a ksh shell in a screen session.
# Syntax: [sessionname]
unset screenk
screenk () {
    env ENV="${HOME}/.kshrc" screen -S "${1:-screenksh}" ksh
}

# ##############################################################################
# Debian

# Function aptinstall - Install packages listed in file.
# Syntax: filename
unset aptinstall
aptinstall () {

    while getopts ':u' option ; do
        case "${option}" in
        u) doupgrade=true;;
        y) assumeyes='-y';;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND=1
  
    if [ ! -r "${1}" ] ; then
        echo "A readable packagelist file must be passed as the first argument. Aborted." 1>&2
        return 1
    fi
  
    typeset pkgslist=$(sed -e 's/#.*$//' "${1}" | grep .)
  
    sudo aptitude update || return 2
  
    if ${doupgrade:-false} ; then
        sudo aptitude upgrade ${assumeyes} || return 11
    fi
  
    sudo aptitude install ${assumeyes} -Z ${pkgslist} || return 21
}

# Function dpkgstat: View installation status of given package names.
# Deps: bash and debian based dpkg command.
# Output: dpkg -s output filtered by '^Package:|^Status:'
# Syntax: {pkg1} {pkg2} ... {pkgN}
unset dpkgstat
dpkgstat () {
    typeset usage='Syntax: ${0} {pkg1} {pkg2} ... {pkgN}'

    [ "${#}" -lt 1 ] && echo "${usage}" && return 1

    dpkg -s "$@" | \
    awk '
        /^Package:/ { pkg = $0; }
        /^Status:/ {
            stat = $0; printf("%-32s%s\n", pkg, stat);
        }'
}

# ##############################################################################
# Disk and sizing functions

# Function dfgb - displays free disk space in GB.
unset dfgb
dfgb () {
    [ -d "$1" ] || return 1
    df -gP "$1" | fgrep "$1" | awk '{print $4}' | cut -d. -f1
}

# Function dubulk - Displays disk usage of filenames read from stdin.
#  Handles massive file lists.
unset dubulk
dubulk () {
    while read filename ; do echo "${filename}" ; done \
    | xargs -n 1000 du -sm
}

# Function dudesc - Displays disk usage of filenames read from stdin.
#  Sorted in descending order.
unset dudesc
dudesc () {
    dubulk | sort -rn
}

# Function dufile - Process data formatted from du, from stdin,
#  yielding back just the filenames.
# Remarks: The original sorting order read from stdin is kept.
# Use case #1: pass filenames to another process that
#  must act on a filesize ordered sequence.
unset dufile
dufile () {
    sed -e 's#^[^[:blank:]]*[[:blank:]][[:blank:]]*##'
}

# Function dugt1 - Displays disk usage of filenames read from stdin which are greater than 1MB.
unset dugt1
dugt1 () {
    dubulk | sed -n -e '/^[1-9][0-9]*[.]/p'
}

# Function dugt1desc - Displays disk usage of filenames read from stdin which are greater than 1MB.
#  Sorted in descending order.
unset dugt1desc
dugt1desc () {
    dubulk | sed -n -e '/^[1-9][0-9]*[.]/p' | sort -rn
}

# Function dugt10 - Displays disk usage of filenames > 10MBm read from stdin.
#  Sorted in descending order.
unset dugt10
dugt10 () {
    dubulk | sed -n -e '/^[1-9][0-9][0-9]*[.]/p'
}

# Function dugt10desc - Displays disk usage of filenames > 10MBm read from stdin.
#  Sorted in descending order.
unset dugt10desc
dugt10desc () {
    dubulk | sed -n -e '/^[1-9][0-9][0-9]*[.]/p' | sort -rn
}

# ##############################################################################
# Java

# Function loadjava - load environment variables based on JAVA_HOME path.
#  Option -v displays JAVA_HOME.
# Syntax: [-v]
unset loadjava
loadjava () {

    typeset doverbose
    typeset isjdk
  
    while getopts ':v' opt ; do
        case "${opt}" in
        v) doverbose=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND=1
  
    if [ -x "${1}/bin/java" ] ; then
        export JAVA_HOME="${1}"
    elif [ ! -x "${JAVA_HOME}/bin/java" ] ; then
        return 1
    fi
  
    if [ -n "${doverbose:-}" ] ; then
        echo "JAVA_HOME=${JAVA_HOME}" 1>&2
    fi
  
    # For JDK also add its root bin and lib subdirectories:
    if [[ ${JAVA_HOME} = *jdk* ]] ; then
        isjdk=true
        PATH="${JAVA_HOME}/lib:${PATH}"
        PATH="${JAVA_HOME}/bin:${PATH}"
    fi
  
    # For JDK the basic JRE binaries are inside the jre subdirectory:
    CLASSPATH="${JAVA_HOME:+${JAVA_HOME}/${isjdk:+jre/}lib/rt.jar}:${CLASSPATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}lib:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}lib/amd64/server:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}bin:${LD_LIBRARY_PATH}"
    LD_LIBRARY_PATH="${JAVA_HOME}/${isjdk:+jre/}bin/client:${LD_LIBRARY_PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}lib:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}lib/amd64/server:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}bin:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}bin/client:${PATH}"
    export CLASSPATH="${CLASSPATH%:}"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH%:}"
    export LIBPATH="${LIBPATH}:${LD_LIBRARY_PATH}"
    export PATH="${PATH%:}"
  
    unset isjdk
}

# ##############################################################################
# Python

# Function addpystartup - Add default .pystartup to home folder.
# No effect if file already exists.
unset addpystartup
addpystartup () {

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

