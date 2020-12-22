#!/usr/bin/env bash

PROGNAME="cb2imagefile.sh"
: ${DS_DIR_IMAGES:=${HOME}/Pictures} ; export DS_DIR_IMAGES

if ! (xclip -selection clipboard -t TARGETS -o | grep -i -q 'image/png') ; then
  echo "${PROGNAME:+$PROGNAME: }SKIP: There is no image in the clipboard." 1>&2
  exit
fi

if [ ! -d "${DS_DIR_IMAGES}" ] ; then mkdir -p "${DS_DIR_IMAGES}" >/dev/null 2>&1 ; fi

xclip -selection clipboard -t "image/png" -o > "${DS_DIR_IMAGES}/clipboard-$(date '+%Y%m%d').png"

if which "${FILEMGR:-thunar}" >/dev/null 2>&1 ; then
  "${FILEMGR:-thunar}" "${DS_DIR_IMAGES}"
fi
