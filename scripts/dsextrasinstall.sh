#!/usr/bin/env bash

dsextras_max_tries=3
dsextras_trial_count=0
while [ ! -e "${DS_HOME:-$HOME/.ds}"/functions/gitextras.sh ] ; do
  echo "Daily Shells Extras installation trial $((dsextras_trial_count+1)) of ${dsextras_max_tries}..."
  dsplugin.sh "bitbucket.org/stroparo/ds-extras" \
    || dsplugin.sh "stroparo/ds-extras"
  dsextras_trial_count=$((dsextras_trial_count+1))
  if [ $dsextras_trial_count -ge $dsextras_max_tries ] ; then
    break
  fi
done
