#!/usr/bin/env bash

PROGNAME="runru.sh"

mv -v ~/.runr ~/.runr.$(date '+%Y%m%d-%OH%OM%OS') || exit $?
runr.sh "$@"
