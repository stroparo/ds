#!/usr/bin/env bash

# Update system packages, with APT for Debian based distros,
# RPM for Enterprise Linux distros etc.

PROGNAME="pkgupdate.sh"

FORCE=false
USAGE="${PROGNAME} [-f] [-h]"

# Options:
OPTIND=1
while getopts ':f' option ; do
  case "${option}" in
    f) FORCE=true;;
    h) echo "$USAGE"; exit;;
  esac
done
shift "$((OPTIND-1))"

# System installers
export APTPROG=apt-get; which apt >/dev/null 2>&1 && export APTPROG=apt
export RPMPROG=yum; which dnf >/dev/null 2>&1 && export RPMPROG=dnf
export RPMGROUP="yum groupinstall"; which dnf >/dev/null 2>&1 && export RPMGROUP="dnf group install"
export INSTPROG="$APTPROG"; which "$RPMPROG" >/dev/null 2>&1 && export INSTPROG="$RPMPROG"

# Check if system update is needed:
updated_more_than_a_day_ago=false
updated_on="$(cat ~/.ds_pkgupdate_date 2>/dev/null)"
: ${updated_on:=00000000}
if [ "$(date '+%Y%m%d')" -gt "${updated_on}" ] ; then
  updated_more_than_a_day_ago=true
fi

if ! ${FORCE} && ! ${updated_more_than_a_day_ago} ; then
  echo "${PROGNAME:+$PROGNAME: }SKIP: Updated more than a day ago." 1>&2
  exit
fi

if egrep -i -q -r 'debian|ubuntu' /etc/*release ; then
  sudo ${INSTPROG} update && sudo ${INSTPROG} upgrade -y
  update_result=$?
elif egrep -i -q -r 'centos|fedora|oracle|red *hat' /etc/*release ; then
  sudo ${INSTPROG} check-update && sudo ${INSTPROG} update
  update_result=$?
fi

if [ ${update_result} -ne 0 ] ; then
  echo "${PROGNAME:+$PROGNAME: }FATAL: There was an error updating the system packages." 1>&2
  exit ${update_result}
fi
