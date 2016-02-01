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
        echoe "FATAL: At least 2 args must be given (destination and at least one source)."
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
                echoe "SKIP: There must be a variable named '${src}'"
                continue
            fi

            typeset srcident="${src}"
            typeset srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                echoe "SKIP: The path pointed to by ${src}='${srcpath}' is not accessible."
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
            echoe "FATAL: '${bakpath}' <= '${srcpath}'"
            return 1
        fi

    done
}

# Function chmodr - Recursively change file mode/permissions. 
# Syntax: dir name_pattern [mode]
unset chmodr
chmodr () {
    typeset mode
    
    [ -z "${1}" -o -z "$2" ] && return 1
  
    mode="${3:-600}"
    [ -z "$3" ] && echoe "mode=${mode}"
  
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
    typeset outputdir='.'
    typeset verbose=''

    # Option processing:
    while getopts ':o:v' opt ; do
        case "${opt}" in
        o)
            outputdir="${OPTARG:-.}"
            ;;
        v)
            verbose=true
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    # Check output directory is writable:
    if [ ! -d "${outputdir}" -o ! -w "${outputdir}" ] ; then
        echoe "FATAL: Output directory '${outputdir}' is not writable."
        return 1
    fi

    for f in "$@" ; do
        export f
        
        case "${f}" in
        
        *.7z)
            if which 7z 2>/dev/null ; then
                which 7z && 7z x -o"${outputdir}" "${f}"
            else
                echoe "WARNING: skipped '${f}' because 7z utility is not available."
                continue
            fi
            ;;
        
        *.tar.bz2|*tbz2)
            if which bunzip2 2>/dev/null ; then
                bunzip2 -c "${f}" | tar -x${verbose:+v}f - -C "${outputdir}"
            else
                echoe "WARNING: skipped '${f}' because bunzip2 utility is not available."
                continue
            fi
            ;;
        
        *.tar.gz|*tgz)
            gunzip -c "${f}" | tar -x${verbose:+v}f - -C "${outputdir}"
            ;;
        
        *.zip)
            if which unzip 2>/dev/null ; then
                unzip "${f}" -d "${outputdir}"
            else
                echoe "WARNING: skipped '${f}' because unzip utility is not available."
                continue
            fi
            ;;
        
        esac
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

