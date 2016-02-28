# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# File handling functions

# Function archive - backup a set of directories which can also be given as variable names.
# Syntax: [-p prefix] {destination-dir} {src-paths|src-path-variable-names}1+
unset archive
archive () {

    typeset pname=archive
    typeset extension='zip'
    typeset prefix='bak'
    typeset sep='-'
    typeset timestamp="$(date '+%Y%m%d-%OH%OM%OS')"

    if ! which zip >/dev/null 2>&1 ; then
        extension='tgz'
    fi

    # Option processing:
    while getopts ':p:' opt ; do
        case "${opt}" in
        p)
            prefix="${OPTARG:-${prefix}}"
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    if [ "$#" -lt 2 ] ; then
        elog -n "$pname" -f "At least 2 args must be given (destination and at least one source)."
        return 1
    fi

    typeset dest="${1}"
    shift

    for src in "$@" ; do

        # Resolving path versus variable indirection:
        if [ -r "${src}" ] ; then
            typeset srcident=$(basename "${src}")
            typeset srcpath="${src}"
        else
            if ! (set | egrep -q "^${src}=") ; then
                elog -n "$pname" -s "There must be a variable named '${src}'"
                continue
            fi

            typeset srcident="${src}"
            typeset srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                elog -n "$pname" -s "The path pointed to by ${src}='${srcpath}' is not accessible."
                continue
            fi
        fi

        typeset bakpath="${dest}/${prefix}${sep}${srcident}${sep}${timestamp}.${extension#.}"

        # Identifying repeated files or variables to be backed up by using indices to tell them apart:
        if [ -e "${bakpath}" ] ; then
            typeset index=1

            while [ -e "${bakpath%.*}-${index}.${extension#.}" ] ; do
                index=$((index + 1))
            done

            bakpath="${bakpath%.*}-${index}.${extension#.}"
        fi

        case "${extension#.}" in
            zip)
                zip -q -r "${bakpath}" "${srcpath}"
                ;;
            tar.gz|tgz)
                tar -cf - -C $(dirname "${srcpath}") $(basename "${srcpath}") | gzip -c - > "${bakpath}"
                ;;
        esac

        if [ "$?" -eq 0 ] ; then
            echo "OK - '${bakpath}' <= '${srcpath}'"
        else
            elog -n "$pname" -f "'${bakpath}' <= '${srcpath}'"
            return 1
        fi

    done
}

# Function childrentgz - archives all srcdir children into destdir/children.tar.gz,
#  via paralleljobs function.
# Remark: abort if destdir already exists.
# Syntax: [-p maxprocesses] srcdir destdir
unset childrentgz
childrentgz () {
    typeset srcdir
    typeset destdir
    typeset maxprocs

    # Options:
    while getopts ':p:' opt ; do
        case "${opt}" in
        p) maxprocs="${OPTARG}";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    srcdir="${1}"
    destdir="${2}"

    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    cd "${srcdir}" || return 99

    paralleljobs ${maxprocs:+-p ${maxprocs}} "tar -cf - {} | gunzip -c - > '${destdir}/{}.tar.gz' ; echo \$?" <<EOF
$(ls -1d *)
EOF
}

# Function childrentgunz - restores all srcdir/*gz children into destdir,
#  via paralleljobs function.
# Remark: abort if destdir already exists.
# Syntax: [-p maxprocesses] srcdir destdir
unset childrentgunz
childrentgunz () {
    typeset srcdir
    typeset destdir
    typeset maxprocs

    # Options:
    while getopts ':p:' opt ; do
        case "${opt}" in
        p) maxprocs="${OPTARG}";;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    srcdir="${1}"
    destdir="${2}"

    # Checks:
    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    if ! ls -1 "${srcdir}"/*.tgz > /dev/null \
    && ! ls -1 "${srcdir}"/*.tar.gz > /dev/null ; then
        elog -w -n "${pname}" "No .tar.gz nor .tgz children to be uncompressed."
        return
    fi

    cd "${destdir}" || return 99

    paralleljobs ${maxprocs:+-p ${maxprocs}} "gunzip -c {} | tar -xf - ; echo \$?" <<EOF
$(ls -1 "${srcdir}"/*.tgz "${srcdir}"/*.tar.gz 2>/dev/null | xargs du -sm | sort -rn | dufile)
EOF
}

# Function chmodr - Recursively change file mode/permissions. 
# Syntax: dir name_pattern [mode]
unset chmodr
chmodr () {

    typeset pname=chmodr
    typeset mode
    
    [ -z "${1}" -o -z "$2" ] && return 1
  
    mode="${3:-600}"
    [ -z "$3" ] && elog -n "$pname" -i "mode=${mode}"
  
    find "${1}" -type f -name "${2}" -exec chmod "${3:-600}" {} \;
}

unset lstgz
lstgz () {
    for f in "$@" ; do
        gunzip -c "${f}" | tar -tf -
    done
}

unset lstxz
lstxz () {
    for f in "$@" ; do
        xz -c -d "${f}" | tar -tf -
    done
}

# Function mv2ymd - Rename a file by appending Ymd of current date as a suffix.
#  Second argument yield one more string before the extension.
# Syntax: filename [additional-suffix]
unset mv2ymd
mv2ymd () {
    [ -e "${1}" ] || return 1
    mv "${1}" "${1%.*}_$(date '+%Y%m%d')${2}.${1##*.}"
}

# Function unarchive - Given a list of archives use the appropriate
#  uncompress command for each. The current directory is the default
#  output directory.
# Syntax: [-o outputdir] [file1[ file2 ...]]
unset unarchive
unarchive () {

    typeset pname=unarchive
    typeset outd='.'
    typeset verbose

    # Option processing:
    while getopts ':o:v' opt ; do
        case "${opt}" in
        o) outd="${OPTARG:-.}" ;;
        v) verbose=true ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    # Check output directory is writable:
    _any_dir_not_w "${outd}" && elog -n "$pname" -f "'${outd}' must be a writable directory." \
    && return 1

    for f in "$@" ; do
        export f
        
        [ -n "${verbose:-}" ] && elog -n "$pname" -i "Unarchiving '${f}'.."

        case "${f}" in
        
        *.7z)
            ! which 7z >/dev/null 2>&1 && elog -n "$pname" -s "'${f}'. 7z program not available." && continue
            7z x -o"${outd}" "${f}"
            ;;
        
        *.tar.bz2|*tbz2)
            ! which bunzip2 >/dev/null 2>&1 && elog -n "$pname" -s "'${f}'. bunzip2 program not available." && continue
            (cd "${outd}" ; bunzip2 -c "${f}" | tar -x${verbose:+v}f -)
            ;;
        
        *.tar.gz|*tgz)
            (cd "${outd}" ; gunzip -c "${f}" | tar -x${verbose:+v}f -)
            ;;
        
        *.zip)
            ! which unzip >/dev/null 2>&1 && elog -n "$pname" -s "'${f}'. unzip program not available." && continue
            unzip "${f}" -d "${outd}"
            ;;
        
        esac

        [ "$?" -eq 0 ] && [ -n "${verbose:-}" ] && elog -n "$pname" -i "Success for '${f}'"
    done
}

unset untgz
untgz () {
    for f in "$@" ; do
        gunzip -c "${f}" | tar -xvf -
    done
}

unset untxz
untxz () {
    for f in "$@" ; do
        xz -c -d "${f}" | tar -xvf -
    done
}

