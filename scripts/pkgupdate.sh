#!/usr/bin/env bash

# Update system packages for both Debian/Ubuntu and Enterprise Linux distros.

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

# Enforce Daily Shells dependency:
if [ ! -e ~/.ds/ds.sh ] ; then
  FORCE=true bash -c "$(curl -LSf -k -o - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')"
fi
. ~/.ds/ds.sh
if [ -z "$DS_HOME" ] ; then
  echo "${PROGNAME:+$PROGNAME: }FATAL: Could not load Daily Shells." 1>&2
  exit 1
fi

linuxordie

# Check if system update is needed:
updated_more_than_a_day_ago=false
updated_on="$(cat ~/.ds_pkgupdate_date 2>/dev/null)"
: ${updated_on:=00000000}
if [ "$(date '+%Y%m%d')" -gt "${updated_on}" ] ; then
  updated_more_than_a_day_ago=true
fi

if ! ${FORCE} && ! ${updated_more_than_a_day_ago} ; then
  echo "${PROGNAME:+$PROGNAME: }SKIP: Updated no more than a day ago." 1>&2
  exit
fi

update_result=1
if _is_debian_family ; then
  sudo ${INSTPROG} update && sudo ${INSTPROG} upgrade -y
  update_result=$?
elif _is_el_family ; then
  sudo ${INSTPROG} check-update && sudo ${INSTPROG} update
  update_result=$?
fi

if [ ${update_result:-1} -ne 0 ] ; then
  echo "${PROGNAME:+$PROGNAME: }FATAL: There was an error updating the system packages." 1>&2
  exit ${update_result}
fi
