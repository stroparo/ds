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
                echo "WARN: zip not available so falling back to tgz." 1>&2
            fi
            ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    [ "$#" -lt 2 ] && echo "FAIL: Min 2 args: destination and sources." 1>&2 && return 10
    dest="${1}"
    shift
    [ ! -d "${dest}" ] && echo "FAIL: Unavailable destination: ${dest}" 1>&2 && return 20

    for src in "$@" ; do

        # Resolving path versus variable indirection:
        if [ -r "${src}" ] ; then
            srcident=$(basename "${src}")
            srcpath="${src}"
        else
            if ! (set | egrep -q "^${src}=") ; then
                echo "SKIP: No file nor variable named '${src}'" 1>&2
                continue
            fi

            srcident="${src}"
            srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                echo "SKIP: ${src}='${srcpath}' is not a readable path." 1>&2
                continue
            fi
        fi

        bakpath="${dest}/${prefix}${sep}${srcident}${sep}${timestamp}.${extension#.}"

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
            echo "OK: '${bakpath}' <= '${srcpath}'" 1>&2
        else
            echo "FAIL: '${bakpath}' <= '${srcpath}'" 1>&2
            return 90
        fi
    done
}

# Function childrentgz - archives all srcdir children into destdir/children.tar.gz,
#  via paralleljobs function.
# Deps: dudesc, dufile, paralleljobs.
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

    srcdir="$(cd ${1}; echo "$PWD")"
    destdir="$(cd ${2}; echo "$PWD")"

    # Gzip compression:
    if ! ${uncompressed} ; then
        if ! [[ $gziplevel = [1-9] ]] ; then
            echo "FAIL: '$gziplevel' not a valid gzip compression level (must be 1..9)." 1>&2
            return 20
        fi
        echo "INFO: Compression level is ${gziplevel}" 1>&2
    fi

    # Checks:
    [ -e "${destdir}" ] && echo "FAIL: Target '${destdir}' already exists." 1>&2 && return 1
    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    cd "${srcdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -cf '${destdir}'/{}.tar {} ; echo \$?"
    else
        paracmd="tar -cf - {} | gzip -${gziplevel:-1} -c - > '${destdir}'/{}.tar.gz ; echo \$?"
    fi

    echo "INFO: Started." 1>&2
    echo "INFO: Initial delay may ocurr whilst sorting file list by size (desc).." 1>&2
    paralleljobs -l "${destdir}" ${maxprocs:+-p ${maxprocs}} "${paracmd}" <<EOF
$(ls -1 -d * | dudesc | dufile)
EOF
    cd - >/dev/null 2>&1
}

# Function childrentgunz - restores all srcdir/*gz children into destdir,
#  via paralleljobs function.
# Deps: dudesc, dufile, paralleljobs.
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

    srcdir="$(cd ${1}; echo "$PWD")"
    destdir="$(cd ${2}; echo "$PWD")"

    # Checks:
    [ -e "${destdir}" ] && echo "FAIL: Target '${destdir}' already exists." 1>&2 && return 1
    mkdir -p "${destdir}" || return 10
    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    if ! ls -1 "${srcdir}"/*.tgz > /dev/null 2>&1 \
    && ! ls -1 "${srcdir}"/*.tar.gz > /dev/null 2>&1 ; then
        echo "WARN: No .tar.gz nor .tgz children to be uncompressed." 1>&2
        return
    fi

    cd "${destdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -xf {} ; echo \$?"
    fi

    echo "INFO: Started." 1>&2
    echo "INFO: Initial delay may ocurr whilst sorting file list by size (desc).." 1>&2
    paralleljobs -l "${destdir}" ${maxprocs:+-p ${maxprocs}} "${paracmd}" <<EOF
$(ls -1 "${srcdir}"/*.tgz "${srcdir}"/*.tar.gz 2>/dev/null | dudesc | dufile)
EOF
    cd - >/dev/null 2>&1
}

# Function chmodr - Recursively change file mode/permissions. 
# Syntax: dir filename_glob [mode=600]
unset chmodr
chmodr () {
    typeset dir fglob mode
    
    dir="${1}"
    fglob="${2}"
    [ ! -d "${dir}" -o -z "${fglob}" ] && return 1
  
    mode="${3:-600}"
    [ -z "$3" ] && echo "Using default mode=${mode}"

    find "${dir}" -type f -name "${fglob}" -exec chmod "${mode}" {} \;
}

# Function getmp3 - Extracts argument file mp3 to arg.mp3 via avconv utility.
unset getmp3
getmp3 () {
    typeset removal

    # Options:
    while getopts ':r' opt ; do
        case "${opt}" in
        r) removal=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    for i in "$@" ; do
        mp3filename="${i%.*}".mp3

        if [ -f "${i}" ] && [ ! -e "${mp3filename}" ] ; then
            if avconv -i "${i}" -threads 3 -acodec libmp3lame -b 128k -vn -f mp3 \
                "${mp3filename}" \
            && [ -n "${removal}" ]
            then
                rm -f "${i}"
            fi
        fi
    done
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

# Function renymd - Rename a file by appending Ymd of current date as a suffix.
#  Second argument yield one more string before the extension.
# Syntax: filenames
unset renymd
renymd () {
    typeset ymdname

    for i in "$@" ; do
        if [ ! -e "${i}" ] ; then
            echo "Skipped abscent file: '${i}'" 1>&2
        else
            ymdname="${i%.*}_$(date '+%Y%m%d').${i##*.}"

            if [ ! -e "${ymdname}" ] ; then
                mv "${i}" "${ymdname}"
            else
                echo "Skipped as already exists: '${ymdname}'" 1>&2
            fi
        fi
    done
}

# Function rentidy - Renames files and directories recursively at the root given by
#  the argument. The new file is as per the function regex.
unset rentidy
rentidy () {
    typeset editspace newfilename prefixintact

    if [[ $(sed --version) != *GNU* ]] ; then
        echo "This will only run with GNU sed."
        return 1
    fi

    while read i ; do
        if [[ $i = */* ]] ; then
            prefixintact="${i%/*}"
            editspace="${i##*/}"
        else
            prefixintact=""
            editspace="${i}"
        fi

        newfilename="$(echo "${editspace}" | \
                sed -e 's/\([a-z]\)\([A-Z]\)/\1-\2/g' | \
                tr '[[:upper:]]' '[[:lower:]]' | \
                sed -e 's/[][ ~_@#(),-]\+/-/g' -e "s/['\"!！]//g")"
        newfilename="${prefixintact:+${prefixintact}/}${newfilename}"

        if [ "${i}" != "${newfilename}" ] ; then
            if [ ! -e "${newfilename}" ] ; then
                echo "'${i}' -> '${newfilename}'"
                mv "${i}" "${newfilename}"
            else
                echo "SKIP as there is a file for '${newfilename}' already."
            fi
        fi
    done <<EOF
$(find "${1:-.}" -depth)
EOF
}

# Function rm1minus2 - Remove arg1's files that are in arg2 (a set op like A1 = A1 - A2).
# Remark: "<(command)" inline file redirection must be available to your shell.
unset rm1minus2
rm1minus2 () {
    while read i ; do
        [ -d "${1}/$i" ] && echo "Ignored directory '${1}/$i'." 1>&2 && continue
        [ -d "${2}/$i" ] && echo "Ignored directory '${2}/$i'." 1>&2 && continue

        sum1=$(md5sum -b "${1}/$i" | cut -d' ' -f1)
        sum2=$(md5sum -b "${2}/$i" | cut -d' ' -f1)

        if [ "${sum1}" = "${sum2}" ] ; then
            rm "${1}/$i"
        else
            echo "Sums differ, thus ignored '${1}/${i}'." 1>&2
        fi
    done <<EOF
$(ls -1 "${1}" | grep -f <(ls -1 "${2}"))
EOF
}

# Function unarchive - Given a list of archives use the appropriate
#  uncompress command for each. The current directory is the default
#  output directory.
# Syntax: [-o outputdir] [file1[ file2 ...]]
unset unarchive
unarchive () {

    typeset force verbose
    typeset pname=unarchive
    typeset outd='.'

    # Option processing:
    while getopts ':fo:v' opt ; do
        case "${opt}" in
        f) force=true;;
        o) outd="${OPTARG:-.}" ;;
        v) verbose=true ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    # Check output directory is writable:
    if _any_dir_not_w "${outd}" ; then
        echo "FAIL: '${outd}' must be a writable directory." 1>&2
        return 1
    fi

    for f in "$@" ; do
        export f
        
        [ -n "${verbose:-}" ] && echo "INFO: Unarchiving '${f}'.." 1>&2

        case "${f}" in
        
        *.7z)
            ! which 7z >/dev/null 2>&1 && echo "SKIP: '${f}'. 7z program not available." 1>&2 && continue
            7z x -o"${outd}" "${f}"
            ;;
        
        *.tar.bz2|*tbz2)
            ! which bunzip2 >/dev/null 2>&1 && echo "SKIP: '${f}'. bunzip2 program not available." 1>&2 && continue
            (cd "${outd}" ; bunzip2 -c "${f}" | tar -x${verbose:+v}f -)
            ;;
        
        *.tar.gz|*tgz)
            (cd "${outd}" ; gunzip -c "${f}" | tar -x${verbose:+v}f -)
            ;;
        
        *.zip)
            ! which unzip >/dev/null 2>&1 && echo "SKIP: '${f}'. unzip program not available." 1>&2 && continue
            unzip "${f}" -d "${outd}"
            ;;
        
        esac

        [ "$?" -eq 0 ] && [ -n "${verbose:-}" ] && echo "OK: '${f}'" 1>&2
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

