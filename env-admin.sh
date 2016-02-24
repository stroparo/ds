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
        echo "A readable packages file must be passed as the first argument. Aborted." 1>&2
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

# Function drop_caches_3: drop I/O caches etcetera TODO review this text.
drop_caches_3 () {
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}

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

# Function paralleljobs - Fires parallel processes, entries read from stdin and
#  replaced by {} expressions of the command specified passed into first argument.
# Syntax: {command-template-with-{}-pairs}
# Example: "gzip '{}'"
unset paralleljobs
paralleljobs () {
    typeset cmd="${1}"
    typeset cmdzero="${1%% *}"
    typeset count=0
    typeset maxprocs=128

    typeset cmdentry
    typeset flatentry

    mkdir -p "${DS_ENV_LOG}/para" || return 1

    while read entry ; do
        [ -z "${entry}" ] && continue

        while [ `jobs -r | wc -l` -ge ${maxprocs} ] ; do
            # sleep 1
            true
        done

        cmdentry="$(echo "${cmd}" | sed -e "s#[{][}]#${entry}#")" || return 1
        flatentry="$(echo "${entry}" | sed -e 's#/#_#g')" || return 1

        count=$((count+1))
        echo "Launching process #${count}.." 1>&2
        echo bash -c "\"${cmdentry}\"" '>' "\"${DS_ENV_LOG}/para/${cmdzero}_${flatentry}.log\"" '2>&1 &'
        nohup bash -c "${cmdentry}" > "${DS_ENV_LOG}/para/${cmdzero}_${flatentry}.log" 2>&1 &
    done

    [ "${count}" -gt 0 ] && echo "Processing last batch of `jobs -p | wc -l` jobs.." 1>&2
    while [ `jobs -r | wc -l` -gt 0 ] ; do sleep 1 ; done
    [ "${count}" -gt 0 ] && echo "Finished processing a total of ${count} entries." 1>&2
}

# Function pgr - pgrep emulator.
# Syntax: [egrep-pattern]
unset pgr
pgr () {
    ps -ef | egrep -i "${1}" | egrep -v "grep.*(${1})"
}

# Function ps1enhance - make PS1 better, displaying user, host, time, $? and the current directory.
ps1enhance () {
    if [ -n "${BASH_VERSION}" ] ; then
        export PS1='[\[\e[32m\]\u@\h\[\e[0m\] \t \$?=$? \W]\$ '
    elif [[ $0 = *ksh* ]] && [[ ${SHELL} = *ksh ]] ; then
        export PS1='[${USER}@$(hostname) $(date '+%OH:%OM:%OS') \$=$? ${PWD##*/}]\$ '
    fi
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

# Function topu - top user processes, or topas when working on AIX.
unset topu
topu () {
    if [[ $(uname) = *AIX* ]] ; then
        topas -U "${USER}" -P
    else
        top -U "${UID:-$(id -u)}"
    fi
}
