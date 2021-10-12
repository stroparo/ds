#!/usr/bin/env bash

# DRYSL - DRY Scripting Library

mountiso () { sudo mount -o loop -t iso9660 "$@" ; }

mountiso "$@"
