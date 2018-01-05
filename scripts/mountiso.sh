#!/usr/bin/env bash

# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

mountiso () { sudo mount -o loop -t iso9660 "$@" ; }

mountiso "$@"
