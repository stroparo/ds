# DS - Daily Shells Library

mungemagic () {
    # Munge descendant bin* and lib* directories to PATH and library variables.
    # Syn: [-a] {directory}
    typeset optafter=""
    if [ "$1" = "-a" ] ; then optafter="-a" ; shift ; fi
    typeset mungeroot="${1}"
    [ -d "$mungeroot" ] || return 1

    # Make mungeroot path canonical:
    mungeroot="$(cd "${mungeroot}"; echo "$PWD")"

    if [ -n "${optafter}" ] ; then
      pathmunge ${optafter} -x $(ls -1d "$mungeroot"/*/ | egrep -v -w 'bin|lib')
    fi

    pathmunge ${optafter} -x $(echo $(find "$mungeroot" -type d -maxdepth 2 -name bin))
    pathmunge ${optafter} -x -v LIBPATH $(echo $(find "$mungeroot" -type d -maxdepth 2 -name lib))

    # Mirror LIBPATH into LD_LIBRARY_PATH:
    if [ -n "${optafter}" ] ; then
      export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${LIBPATH}"
    else
      pathmunge -x $(ls -1d "$mungeroot"/*/ | egrep -v -w 'bin|lib')
      export LD_LIBRARY_PATH="${LIBPATH}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    fi
}
