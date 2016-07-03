#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# Purpose:
# In current directory tree, copy all regular files to a temporary and
# then move back to the old name. This will change ownership to the
# current user, emulating chown behavior.
# Finally, the script prints the new file listing.

# Arguments:
# None (acts on current directory).

# ##############################################################################
# Main

find . -type f | while read f; do
  cp "${f}" "${f}".tmpxyz \
  && rm -f "${f}" \
  && mv "${f}".tmpxyz "${f}"
done

find . -type f | xargs ls -ld
