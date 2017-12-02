#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Info: Finds scripts in root dirs passed as arguments.

typeset re_shells='perl|python|ruby|sh'

awk 'FNR == 1 && $0 ~ /^#!.*('"$re_shells"') */ { print FILENAME; }
    FNR > 1 { nextfile; }' \
    $(find "$@" -type f | egrep -v '[.](git|hg|svn)')
