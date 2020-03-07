#!/bin/bash

# Info: Finds scripts in root dirs passed as arguments.

if [ $# -eq 0 ] ; then exit ; fi

for dir in "$@" ; do
  find "${dir}" -type f \( -name '*.sh' -o -name '*.[ck]sh' -o -name '*.pl' -o -name '*.py' -o -name '*.rb' \)
done
