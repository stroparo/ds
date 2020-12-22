#!/usr/bin/env bash

PROGNAME="cb2imagefile.sh"

if ! (xclip -selection clipboard -t TARGETS -o | grep -i -q 'image/png') ; then
  echo "${PROGNAME:+$PROGNAME: }SKIP: There is no image in the clipboard." 1>&2
  exit
fi

if [ -d "${1}" ] ; then
  FINAL_DIR="${1}"
else
  FINAL_DIR="${DS_DIR_IMAGES:-${HOME}/Pictures}"
fi
if [ ! -d "${FINAL_DIR}" ] ; then
  mkdir -p "${FINAL_DIR}" >/dev/null 2>&1
fi

xclip -selection clipboard -t "image/png" -o > "${FINAL_DIR}/clipboard-$(date '+%Y%m%d').png"

if which "${FILEMGR:-thunar}" >/dev/null 2>&1 ; then
  "${FILEMGR:-thunar}" "${FINAL_DIR}"
fi
