#!/usr/bin/env bash

# DS - DRYSL (DRY Scripting Library)

# Info: Get firefox cookies & write them to a file in old netscape (or wget) format.
# Syntax: {mozilla's cookies sqlite db} {target cookies filename} {domain pattern/regex}

typeset agent_cookies="${1}"
typeset target_cookies="${2}"
typeset inet_domain_pattern="${3}"

if [ ! -e "${target_cookies}" ] ; then
    sqlite3 "${agent_cookies}" <<EOF
.output ${target_cookies}
.mode tabs
-- select basedomain, 'TRUE', path, issecure, expiry, name, value from moz_cookies where baseDomain like '%domain%';
select basedomain, 'TRUE', path, 'FALSE', expiry, name, value from moz_cookies where baseDomain like '%${inet_domain_pattern}%';
.quit
EOF
fi
