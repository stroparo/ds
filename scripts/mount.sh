#!/usr/bin/env bash

PROGNAME="mount.sh"

mount () {
  typeset result=0

  for mount_point in "$@" ; do

    if [ ! -d "${mount_point}" ] ; then
      echo "${PROGNAME}: SKIP: No mount point '${mount_point}'." 1>&2
      continue
    fi

    if ! grep -q "${mount_point}" /etc/fstab ; then
      echo "${PROGNAME}: SKIP: mount point '${mount_point}' not in fstab." 1>&2
      return
    elif grep -q "${mount_point}" /etc/mtab ; then
      echo "${PROGNAME}: SKIP: Already mounted." 1>&2
      return
    else
      if ! sudo mount "${mount_point}" ; then
        result=1
      fi
    fi
  done

  return ${result}
}

mount "$@"
