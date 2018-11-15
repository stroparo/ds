#!/usr/bin/env bash

# Info: scale an image file (with imagemagick's convert).
# Syntax: {filename} {argument for imagemagick -scale option}

if [ "$#" -ne 2 ] || [ -z "${1}" ] || [ -z "${2}" ] ; then
  echo "Usage: $(basename "${0}") file geometry"
  exit 1
fi

echo "Scaling '${1}' to '${2}'.." 1>&2

convert "${1}" -scale "${2}" "${1}2"
mv -f "${1}2" "${1}"

