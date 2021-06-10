_is_vnc_active () { [ 0 -lt "$(ps -ef | grep -w '/usr/bin/[^ ]*vnc' | grep -v grep | wc -l)" ] ; }
_is_vnc_inactive () { [ 0 -eq "$(ps -ef | grep -w '/usr/bin/[^ ]*vnc' | grep -v grep | wc -l)" ] ; }
