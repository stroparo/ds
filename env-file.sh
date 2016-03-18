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
    typeset bakpath dest src srcident srcpath
    typeset pname=archive
    typeset extension='tgz'
    typeset prefix='bak'
    typeset sep='-'
    typeset timestamp="$(date '+%Y%m%d-%OH%OM%OS')"

    # Options:
    while getopts ':p:z' opt ; do
        case "${opt}" in
        p) prefix="${OPTARG:-${prefix}}" ;;
        z)
            if which zip >/dev/null 2>&1 ; then
                extension=zip
            else
                elog -w -n "${pname}" "zip not available so falling back to tgz."
            fi
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    [ "$#" -lt 2 ] && elog -f -n "$pname" "Min 2 args: destination and sources." && return 10
    typeset dest="${1}"
    shift
    [ ! -d "${dest}" ] && elog -f -n "$pname" "Unavailable destination: ${dest}" && return 20

    for src in "$@" ; do

        # Resolving path versus variable indirection:
        if [ -r "${src}" ] ; then
            typeset srcident=$(basename "${src}")
            typeset srcpath="${src}"
        else
            if ! (set | egrep -q "^${src}=") ; then
                elog -s -n "$pname" "No file nor variable named '${src}'"
                continue
            fi

            typeset srcident="${src}"
            typeset srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                elog -s -n "$pname" "${src}='${srcpath}' is not a readable path."
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
            zip) zip -q -r "${bakpath}" "${srcpath}" ;;
            *)
                tar -cf - -C $(dirname "${srcpath}") $(basename "${srcpath}") \
                | gzip -c - > "${bakpath}"
                ;;
        esac

        if [ "$?" -eq 0 ] ; then
            elog -n "$pname" "OK - '${bakpath}' <= '${srcpath}'"
        else
            elog -f -n "$pname" "'${bakpath}' <= '${srcpath}'"
            return 90
        fi
    done
}

# Function childrentgz - archives all srcdir children into destdir/children.tar.gz,
#  via paralleljobs function.
# Deps: dudesc, dufile, elog, paralleljobs.
# Remark: abort if destdir already exists.
# Syntax: [-p maxprocesses] srcdir destdir
unset childrentgz
childrentgz () {
    typeset srcdir destdir maxprocs paracmd
    typeset gziplevel=1
    typeset uncompressed=false

    # Options:
    while getopts ':c:p:u' opt ; do
        case "${opt}" in
        c) gziplevel="${OPTARG}";;
        p) maxprocs="${OPTARG}";;
        u) uncompressed=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    srcdir="${1}"
    destdir="${2}"

    # Gzip compression:
    if ! ${uncompressed} ; then
        if ! [[ $gziplevel = [1-9] ]] ; then
            elog -f "'$gziplevel' not a valid gzip compression level (must be 1..9)."
            return 20
        fi
        elog "Compression level is ${gziplevel}"
    fi

    # Checks:
    [ -e "${destdir}" ] && elog -f "Target '${destdir}' already exists." && return 1
    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    cd "${srcdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -cf '${destdir}'/{}.tar {} ; echo \$?"
    else
        paracmd="tar -cf - {} | gzip -${gziplevel:-1} -c - > '${destdir}'/{}.tar.gz ; echo \$?"
    fi

    elog "Started."
    elog "Initial delay may ocurr whilst sorting file list by size (desc).."
    paralleljobs -l "${destdir}" ${maxprocs:+-p ${maxprocs}} "${paracmd}" <<EOF
$(ls -1 -d * | dudesc | dufile)
EOF
}

# Function childrentgunz - restores all srcdir/*gz children into destdir,
#  via paralleljobs function.
# Deps: dudesc, dufile, elog, paralleljobs.
# Remark: abort if destdir already exists.
# Syntax: [-p maxprocesses] srcdir destdir
unset childrentgunz
childrentgunz () {
    typeset srcdir destdir maxprocs
    typeset paracmd="gunzip -c {} | tar -xf - ; echo \$?"
    typeset uncompressed=false

    # Options:
    while getopts ':p:u' opt ; do
        case "${opt}" in
        p) maxprocs="${OPTARG}";;
        u) uncompressed=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    srcdir="${1}"
    destdir="${2}"

    # Checks:
    [ -e "${destdir}" ] && elog -f "Target '${destdir}' already exists." && return 1
    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    if ! ls -1 "${srcdir}"/*.tgz > /dev/null 2>&1 \
    && ! ls -1 "${srcdir}"/*.tar.gz > /dev/null 2>&1 ; then
        elog -w -n "${pname}" "No .tar.gz nor .tgz children to be uncompressed."
        return
    fi

    cd "${destdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -xf {} ; echo \$?"
    fi

    elog "Started."
    elog "Initial delay may ocurr whilst sorting file list by size (desc).."
    paralleljobs -l "${destdir}" ${maxprocs:+-p ${maxprocs}} "${paracmd}" <<EOF
$(ls -1 "${srcdir}"/*.tgz "${srcdir}"/*.tar.gz 2>/dev/null | dudesc | dufile)
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

