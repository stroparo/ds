#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Purpose:
# This script sorts all words in the file and puts
#  them in the second filename one per line.

# Syntax:
syntax='Syntax: {source-file} {destination-file}'

sortwords () {
    awk '
    BEGIN {
        FS="[|,;.: \r\t\n]+";
        RS="";
        ORS="";
    }
    {
        for (x = 1; x <= NF; x++) {
            print $x"\n";
            x++;
        }
    }' "${1}" \
    | sort \
    > "${2}" \
    || return 1
}

# Option processing:
if [ -z "${1}" -o -z "${2}" ]; then
  echo "${syntax}"
  exit 1
fi

sortwords "${1}" "${2}" || exit 1
