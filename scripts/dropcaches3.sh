#!/usr/bin/env sh

# DS - Daily Shells Library

sudo cat > /proc/sys/vm/drop_caches <<EOF
3
EOF

