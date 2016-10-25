# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# File handling

# Function archive - backup a set of directories which can also be given as variable names.
# Syntax: [-p prefix] {destination-dir} {src-paths|src-path-variable-names}1+
unset archive
archive () {
    typeset oldind="$OPTIND"
    typeset bakpath dest src srcident srcpath
    typeset pname=archive
    typeset extension='tgz'
    typeset prefix='bak'
    typeset sep='-'
    typeset timestamp="$(date '+%Y%m%d-%OH%OM%OS')"

    OPTIND=1
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
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

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
            srcident="${src}"
            srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                echo "SKIP: '${src}' is not a readable path nor a variable (value='${srcpath}')." 1>&2
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
# Syntax: [-c gziplevel] [-p maxprocesses] [-u] [-w] srcdir destdir
# Options:
#   -u triggers uncompressed tars
#   -w triggers waiting for the last background process
unset childrentgz
childrentgz () {
    typeset oldind="$OPTIND"
    typeset srcdir destdir maxprocs paracmd dowait
    typeset gziplevel=1
    typeset uncompressed=false

    OPTIND=1
    while getopts ':c:p:uw' opt ; do
        case "${opt}" in
        c) gziplevel="${OPTARG}";;
        p) maxprocs="${OPTARG}";;
        u) uncompressed=true;;
        w) dowait=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    # Checks:

    # Gzip compression:
    if ! ${uncompressed} ; then
        if ! [[ $gziplevel = [1-9] ]] ; then
            echo "FAIL: '$gziplevel' not a valid gzip compression level (must be 1..9)." 1>&2
            return 20
        fi
        echo "INFO: Compression level is ${gziplevel}" 1>&2
    fi

    if [ -e "${2}" ] ; then
        echo "FAIL: Target '${2}' already exists." 1>&2
        return 1
    fi
    mkdir -p "${2}" || return 10

    srcdir="$(cd "${1}"; echo "$PWD")"
    destdir="$(cd "${2}"; echo "$PWD")"

    if [ ! -d "$1" ] || [ ! -r "${srcdir}" ] ; then
        echo "Not a readable source dir ('$1'). Aborted." 1>&2
        return 20
    fi
    if [ ! -d "$2" ] || [ ! -w "${destdir}" ] ; then
        echo "Not a writable destination dir ('$2'). Aborted." 1>&2
        return 30
    fi

    # Main:

    cd "${srcdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -cf '${destdir}'/{}.tar {}"
    else
        paracmd="tar -cf - {} | gzip -${gziplevel:-1} -c - > '${destdir}'/{}.tar.gz"
    fi

    echo "INFO: Started." 1>&2
    echo "INFO: Initial delay may ocurr whilst sorting file list by size (desc).." 1>&2
    paralleljobs -l "${destdir}" ${maxprocs:+-p ${maxprocs}} "${paracmd}" <<EOF
$(ls -1 -d * | dudesc | dufile)
EOF
    cd - >/dev/null 2>&1

    if [ -n "$dowait" ] ; then
        wait || return 1
    fi
}

# Function childrentgunz - restores all srcdir/*gz children into destdir,
#  via paralleljobs function.
# Deps: dudesc, dufile, paralleljobs.
# Remark: abort if destdir already exists.
# Syntax: [-p maxprocesses] srcdir destdir
unset childrentgunz
childrentgunz () {
    typeset oldind="$OPTIND"
    typeset srcdir destdir maxprocs
    typeset paracmd="gunzip -c {} | tar -xf -"
    typeset uncompressed=false

    OPTIND=1
    while getopts ':p:u' opt ; do
        case "${opt}" in
        p) maxprocs="${OPTARG}";;
        u) uncompressed=true;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    # Checks:

    if [ -e "${2}" ] ; then
        echo "FAIL: Target '${2}' already exists." 1>&2
        return 1
    fi
    mkdir -p "${2}" || return 10
    srcdir="$(cd "${1}"; echo "$PWD")"
    destdir="$(cd "${2}"; echo "$PWD")"

    [ -r "${srcdir}" ] || return 20
    [ -w "${destdir}" ] || return 30

    if ! ls -1 "${srcdir}"/*.tgz > /dev/null 2>&1 \
    && ! ls -1 "${srcdir}"/*.tar.gz > /dev/null 2>&1 ; then
        echo "WARN: No .tar.gz nor .tgz children to be uncompressed." 1>&2
        return
    fi

    # Main:

    cd "${destdir}" || return 99

    if ${uncompressed} ; then
        paracmd="tar -xf {}"
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

# Function loc - search via locate program.
# Purpose: wrap and interpolate arguments with a literal '*'
#  and execute 'locate -bi {wrapped_args}'. It avoids running
#  locate with just an '*' i.e. you have to pass at least a
#  non-empty argument.
# Syntax: chunk1 [chunk2 ...]
unset loc
loc () {
  [[ -z ${1} ]] && return 1
  typeset locvalue='*'
  for i in "$@" ; do locvalue="${locvalue}${i}*" ; done
  locate -bi "${locvalue}"
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

# Function rentidyedit - rentidy helper.
unset rentidyedit
rentidyedit () {
    echo "${1}" | \
        sed -e 's/\([a-z]\)\([A-Z]\)/\1-\2/g' | \
        tr '[[:upper:]]' '[[:lower:]]' | \
        sed -e 's/[][ ~_@#(),-]\+/-/g' -e "s/['\"!！]//g" | \
        sed -e 's/-[&]-/-and-/g' | \
        sed -e 's/-*[.]-*/./g'
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

        newfilename="$(rentidyedit "${editspace}")"
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
    typeset oldind="$OPTIND"
    typeset pname=unarchive

    typeset exclude='@@@@DUMMYEXCLUDE@@@@'
    typeset force
    typeset outd='.'
    typeset verbose

    OPTIND=1
    while getopts ':fo:vx:' opt ; do
        case "${opt}" in
        f) force=true;;
        o) outd="${OPTARG:-.}" ;;
        v) verbose=true ;;
        x) exclude="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    # Check output directory is writable:
    if _any_dir_not_w "${outd}" ; then
        echo "FAIL: '${outd}' must be a writable directory." 1>&2
        return 1
    fi

    for f in "$@" ; do
        export f

        if echo "${f}" | egrep -i -q "${exclude}" ; then
            continue
        fi

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

        *.tar.xz|*txz)
            (cd "${outd}" ; xz -c -d "${f}" | tar -x${verbose:+v}f -)
            ;;

        *.zip)
            ! which unzip >/dev/null 2>&1 && echo "SKIP: '${f}'. unzip program not available." 1>&2 && continue
            unzip "${f}" -d "${outd}"
            ;;

        esac

        if [ "$?" -eq 0 ] && [ -n "${verbose:-}" ] ; then
            echo "OK: '${f}'" 1>&2
        fi
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

# Function xzp - (De)compress set ox xz files, also traverse given dirs looking for xz.
#
# Syntax: [-d] [-t {target root}] filenames...
#
# Options:
# -d
#   Indicates decompression mode. Omitting it yields the default compression mode.
#
# Remark: The target root is going to be a common root for several source directories
#   even when those sources are in separate dir trees in the filesystem all the way up
#   to the root. Also, a target being specified implies xz's -c (--keep).
unset xzp
xzp () {
    typeset cmd copycmd decompress maxprocs target
    typeset compressedfiles files2copy inflatedfiles
    typeset oldind="$OPTIND"

    OPTIND=1
    while getopts ':dp:t:' opt ; do
        case "${opt}" in
        d) decompress='-d' ;;
        p) maxprocs="${OPTARG}" ;;
        t) target="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND="${oldind}"

    # Set command to place output files to specified target if one was passed in:
    if [ -n "${target}" ] ; then
        if [ ! -d "${target}" -o ! -w "${target}" ] ; then
            elog -f -n xzp "Target path (${target}) is not writable."
            return 1
        fi

        cmd='tgt="'"${target}"'"/{} ; mkdir -p "$(dirname "${tgt}")"'

        copycmd="${cmd}"' ; cp {} "${tgt}"'

        if [ -n "${decompress}" ] ; then
            cmd="${cmd}"' ; xz -c -d {} > "${tgt%.xz}"'
        else # compress
            cmd="${cmd}"' ; xz -c -4 {} > "${tgt}.xz"'
        fi
    else
        cmd="xz ${decompress:--4} {}"
    fi

    # Files:
    compressedfiles=$(eval ls -1dF '"$@"' | grep '[.]xz$')
    inflatedfiles=$(eval ls -1dF '"$@"' | grep -v '[.]xz$' | grep -v '/$')

    # Complement files to be just copied:
    if [ -n "${decompress}" ] ; then
        files2copy="${inflatedfiles}"
    else # compress
        files2copy="${compressedfiles}"
    fi

    # Main action (compress | decompress):
    paralleljobs -p "${maxprocs}" -z xz "${cmd}" <<EOF
${files}
EOF

    # Copy complement files only if a target was specified:
    if [ -n "${target}" ] ; then
        paralleljobs -p "${maxprocs}" "${copycmd}" <<EOF
${files2copy}
EOF
    fi

    # Dirs:
#    for d in "$@" ; do
#        if [ -d "$d" ] ; then
#            cd "${d}"
#            # cat <<EOF
#            paralleljobs -p "${maxprocs}" -z xz "${cmd}" <<EOF
#$(find . -name '*.xz' -type f)
#EOF
#            cd - >/dev/null 2>&1
#        fi
#    done

}

# ##############################################################################
# Disk and sizing functions

# Function dfgb - displays free disk space in GB.
unset dfgb
dfgb () {
    typeset dfdir="${1:-.}"
    typeset freegb

    [ -d "${dfdir}" ] || return 10

    freegb=$(df -gP "${dfdir}" | tail -n +2 | tail -n 1 | awk '{print $4}' | cut -d'.' -f1) \
    || return 20

    echo "${freegb}"
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
