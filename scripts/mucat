#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Info: Cat multiple files. Sends '==> filename <==' to stderr before each cat.
# Syntax: mucat file1[ file2[ file3 ...]]

typeset first=true

for f in "$@" ; do
    ${first} || echo '' 1>&2

    echo "==> ${f} <==" 1>&2
    cat "${f}"

    first=false
done
