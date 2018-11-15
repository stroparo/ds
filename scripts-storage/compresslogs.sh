#!/usr/bin/env bash

MIN_DAYS=${1:-7}
MIN_SIZE=${2:-10}

while read file ; do
  filesize=$(du -sm "$file" | awk '{print $1}')
  if [ ${filesize:-0} -gt ${MIN_SIZE:-10} ] ; then
    ls -l "$file"
    gzip -v "$file"
  fi
done <<EOF
$(find . -type f -mtime +${MIN_DAYS:-7} -name \*log\* ! -name '*gz')
EOF
