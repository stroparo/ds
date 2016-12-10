#!/usr/bin/env sh

# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

sudo cat > /proc/sys/vm/drop_caches <<EOF
3
EOF

