# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

mucat () {
    # Info: Cat multiple files.
    # Syntax: mucat file1[ file2[ file3 ...]]

    typeset first=true

    for f in "$@" ; do
        ${first} || echo ''

        echo "==> ${f} <=="
        cat "${f}"

        first=false
    done
}

