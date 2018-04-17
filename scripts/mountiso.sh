#!/usr/bin/env bash

# Daily Shells Library

mountiso () { sudo mount -o loop -t iso9660 "$@" ; }

mountiso "$@"
