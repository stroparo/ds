#!/usr/bin/env bash

# DS - Daily Shells Library
# License:
#   See README.md document in projects page at
#   https://github.com/stroparo/ds

# Purpose:
# Set a PPTP vpn up for Linux.

# ##############################################################################
# Functions

setvpnpptp () {
    typeset usage='setvpnpptp {connection name} {host address[|other hosts up script]} [up command]'

    typeset conn_name="$1"
    typeset host="${2%%|*}"
    typeset otherhosts="${2#*|}"
    typeset ifupcommands="$3"
    typeset user pass
    typeset vpnpptpconf="/etc/ppp/ip-up.d/${conn_name}"
    typeset vpnpptppeer="/etc/ppp/peers/${conn_name}"

    if ! [[ "$(uname -a)" = *[Ll]inux* ]] ; then
        echo 'The setvpnpptp function only supports Linux environments.' 1>&2
        return 1
    fi

    if [ -z "$host" -o -z "$conn_name" ] ; then
        echo 'Must have the host passed in the first argument.' 1>&2
        return 1
    fi

    echo "Enter user:" ; read user
    echo "Enter pass:" ; read pass

    sudo tee "$vpnpptppeer" >/dev/null <<EOF
pty "pptp ${host} --nolaunchpppd"
name ${user}
password ${pass}
remotename PPTP
require-mppe-128
EOF

    if [ -n "$ifupcommands" ] ; then
        sudo tee "$vpnpptpconf" <<PPPEOF
#!/usr/bin/env bash

case \$5 in

${host}${otherhosts:+|${otherhosts}})

    > /etc/ppp/peer_${conn_name}.log 2>&1
    while read cmd ; do
        echo "$cmd" >> /etc/ppp/peer_${conn_name}.log 2>&1
        eval "$cmd" >> /etc/ppp/peer_${conn_name}.log 2>&1
    done <<EOF
${ifupcommands}
EOF
    ;;
esac
PPPEOF
    fi

    sudo chmod 755 "$vpnpptpconf"
    sudo chmod 600 "$vpnpptppeer"
    ls -l "$vpnpptpconf" "$vpnpptppeer"
}

# ##############################################################################
# Main

# Call it only if not interactive (not sourced):
if [ "$#" -gt 1 ] ; then
    setvpnpptp "$@"
    exit "$?"
fi
