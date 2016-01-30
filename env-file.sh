# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# File handling functions

# Function archive - backup a set of directories which can also be given as variable names.
# Syntax: [-p prefix] {destination-dir} {src-paths|src-path-variable-names}1+
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
        echo 'At least 2 args must be given (destination and at least one source).' 1>&2
        echo 'Aborted.' 1>&2
        return
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
                echo "There is not a variable named '${src}'. Skipped." 1>&2
                continue
            fi

            typeset srcident="${src}"
            typeset srcpath="$(eval echo "\$${src}")"

            if [ ! -r "${srcpath}" ] ; then
                echo "The path pointed to by ${src}='${srcpath}' is not accessible. Skipped." 1>&2
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
            echo "FAIL - '${bakpath}' <= '${srcpath}'" 1>&2
            echo 'Aborted.' 1>&2
            return
        fi

    done
}

# Function chmodr - Recursively change file mode/permissions. 
# Syntax: dir name_pattern [mode]
chmodr () {
    typeset mode
    
    [ -z "${1}" -o -z "$2" ] && return 1
  
    mode="${3:-600}"
    [ -z "$3" ] && echo "mode=${mode}" 1>&2
  
    find "${1}" -type f -name "${2}" -exec chmod "${3:-600}" {} \;
}

lstgz () {
  for f in "$@" ; do
    gunzip -c "${f}" | tar -tf -
  done
}

lstxz () {
  for f in "$@" ; do
    xz -c -d "${f}" | tar -tf -
  done
}

# Function mv2ymd: Rename a file by appending Ymd of current date as a suffix.
#  Second argument yield one more string before the extension.
# Syntax: filename [additional-suffix]
mv2ymd () {
    [ -e "${1}" ] || return 1
    mv "${1}" "${1%.*}_$(date '+%Y%m%d')${2}.${1##*.}"
}

untgz () {
  for f in "$@" ; do
    gunzip -c "${f}" | tar -xvf -
  done
}

untxz () {
  for f in "$@" ; do
    xz -c -d "${f}" | tar -xvf -
  done
}

