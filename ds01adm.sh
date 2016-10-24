# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops functions

cthttpd () { sudo "/etc/init.d/apache${2:-2}"  "${1:-restart}" ; }
ctlamp () { sudo "${LAMPHOME}/ctlscript.sh"   "${1:-restart}" ; }
ctpg () { sudo "/etc/init.d/postgresql${2}" "${1:-restart}" ; }
dropcaches3 () { echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null ; }
pgr () { ps -ef | egrep -i ${options} "$@" | egrep -v "grep.*(${1})" ; }
setautobash () { echo 'if [[ $- = *i* ]] && [ -z "${BASH_VERSION}" ] ; then bash ; fi' >> "$HOME/.profile" ; }
setvi () { echo 'set -o vi' | tee -a "$HOME/.profile" "$HOME/.bashrc" ; }

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

unset mungebinlib
mungebinlib () {

    typeset mungeroot="$1"

    if [ ! -e "$mungeroot" ] ; then return ; fi

    pathmunge -x $(find "$mungeroot" -name 'bin*' -type d)
    pathmunge -a -x -v LIBPATH $(find "$mungeroot" -name 'lib*' -type d)
    export LD_LIBRARY_PATH="$LIBPATH${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

# ##############################################################################
# Java

# Function loadjava - load environment variables based on JAVA_HOME path.
#  Option -v displays JAVA_HOME.
# Syntax: [-v] [JAVA_HOME override]
unset loadjava
loadjava () {
    typeset oldind="${OPTIND}"
    typeset doverbose
    typeset isjdk

    OPTIND=1
    while getopts ':v' opt ; do
        case "${opt}" in
        v) doverbose=true ;;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

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
    PATH="${JAVA_HOME}/${isjdk:+bin:${JAVA_HOME}/jre/}bin:${PATH}"
    PATH="${JAVA_HOME}/${isjdk:+jre/}bin/client:${PATH}"
    export CLASSPATH="${CLASSPATH%:}"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH%:}"
    export LIBPATH="${LIBPATH}:${LD_LIBRARY_PATH}"
    export PATH="${PATH%:}"

    unset isjdk
}

# ##############################################################################
