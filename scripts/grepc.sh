#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# Purpose:
# This script emulates grep with context operations.
#  Default context i.e. before and after is 10 lines
#  around the matching position.

# Syntax: [-a afterlines] [-b beforelines] [-c contextlines]

grepc () {
    typeset afterlines
    typeset beforelines
    typeset contextlines=10

    while getopts ':a:b:c:' opt ; do
        case "${opt}" in
        a) afterlines="${OPTARG}" ;;
        b) beforelines="${OPTARG}" ;;
        c) contextlines="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND - 1)) ; OPTIND=1

    : ${afterlines:=${contextlines}}
    : ${beforelines:=${contextlines}}

    grep -n "$@" /dev/null | \
    while IFS=: read filename lineno matched ; do
        echo '================================================='
        echo "${filename}:${lineno}:${matched}"

        start=$((lineno - beforelines))
        [ "${start}" -lt 1 ] && start=1

        end=$((lineno + afterlines))

        echo "${start}:${end}"
        sed -n -e "${start},${end}p" "${filename}"

        echo ''
    done
}

grepc "$@"
