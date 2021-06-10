_is_vnc_active () { test 0 -lt "$(ps -ef | grep -w '/usr/bin/[^ ]*vnc' | grep -v grep | wc -l)" ; }
_is_vnc_inactive () { test 0 -eq "$(ps -ef | grep -w '/usr/bin/[^ ]*vnc' | grep -v grep | wc -l)" ; }
