# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops functions

ctht () { sudo "/etc/init.d/apache${2:-2}"  "${1:-restart}" ; }
ctlamp () { "${LAMPHOME}/ctlscript.sh" "${1:-restart}" ; }
ctpg () { sudo "/etc/init.d/postgresql${2}" "${1:-restart}" ; }

alertdeadproc () {
    # Awaits found processes to finish then starts beeping until interrupted.
    # Syn: {ERE to filter ps output}
    while pgr "${1}" > /dev/null ; do sleep 1 ; done
    while true ; do echo '\a' ; sleep 8 ; done
}

autobash () {
    # Updates $HOME/.profile to call bash on interactive sessions.
    appendunique \
        'if [[ $- = *i* ]] && [ -z "${BASH_VERSION}" ] ; then bash ; fi' \
        "$HOME/.profile"
}

autovimode () {
    # Updates .bashrc and .profile at $HOME with 'set -o vi'.
    appendunique 'set -o vi' "$HOME/.bashrc" "$HOME/.profile"
}

dropcaches3 () {
    # (Linux) Drops caches with the '3' command (see 'man drop_caches').
    _is_linux || return
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
}

makeat () {
    # Call configure, make & makeinstall for custom dir/prefix.
    # Default prefix is ~/opt/root
    # Syn: {prefix directory}

    mkdir "${1:-${HOME}/opt/root}" 2> /dev/null || return 1

    ./configure --prefix="${1:-${HOME}/opt/root}" && \
        make && \
            make install
}

mungebinlib () {
    # Munge descendant bin* and lib* directories to PATH and library variables.
    # Syn: {directory}

    typeset mungeroot="$1"
    [ -e "$mungeroot" ] || return 1

    pathmunge -x $(find "$mungeroot" -name 'bin*' -type d)
    pathmunge -a -x -v LIBPATH $(find "$mungeroot" -name 'lib*' -type d)
    export LD_LIBRARY_PATH="$LIBPATH${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
}

pgr () {
    # pgrep emulator.
    # Syn: {ERE to filter ps output}
    ps -ef | egrep -i "$1" | egrep -v "grep.*(${1})"
}

topu () {
    # Outputs top info for user processes, or topas when called in AIX.
    if _is_aix ; then
        topas -U "${USER}" -P
    else
        top -U "${UID:-$(id -u)}"
    fi
}

# ##############################################################################
# Java

loadjava () {
    # Loads environment variables based on JAVA_HOME path.
    # Syn: [-v] [JAVA_HOME override]
    # -v displays JAVA_HOME.

    typeset doverbose
    typeset isjdk # false repr must be empty value for later param expansion.

    typeset oldind="${OPTIND}"
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
}

# ##############################################################################
