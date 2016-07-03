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

# ##############################################################################
# Deployment / Installation

# Function deploypackages - install software
# Option -c asks for prior user confirmation.
unset deploypackages
deploypackages () {

    typeset pname=deploypackages

    typeset userconfirm
    if [ "$1" = '-c' ] ; then userconfirm=true ; shift ; fi

    typeset pkgspath="${1}"
    typeset deploypath="${2}"

    if ${userconfirm:-false} ; then
        userconfirm "Deploy packages from '${pkgspath}' ?" || return
    fi

    if [ -z "$(ls -1 "${pkgspath}" 2>/dev/null | egrep '([.]7z|[.]zip|bz2|gz)$')" ] ; then
        elog -n "$pname" -f "No packages in '${pkgspath}'."
        return 1
    fi

    elog -n "$pname" "Packages path '${pkgspath}' .."
    elog -n "$pname" ".. deploying to '${deploypath}' .."

    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*.7z 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*.zip 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*bz2 2>/dev/null)
    unarchive -v -o "${deploypath}" $(ls -1 "${pkgspath}"/*gz 2>/dev/null)

    elog -n "$pname" 'Complete.'
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
