#!/usr/bin/env bash

PROGNAME="bluetoothwin.sh"

WINDIR="$1"

if ! which chntpw >/dev/null 2>&1 ; then
  echo "${PROGNAME:+$PROGNAME: }FATAL: Install chntpw utility program first. On Debian/Ubuntu-based distros:" 1>&2
  echo "${PROGNAME:+$PROGNAME: }FATAL: sudo apt-get update && sudo apt-get install chntpw" 1>&2
  exit 1
fi

cd "${WINDIR:=/mnt/c/Windows}/System32/config"
if [ "$PWD" != "${WINDIR}/System32/config" ] ; then
  echo "${PROGNAME:+$PROGNAME: }FATAL: Could not cd to '${WINDIR}/System32/config'." 1>&2
  exit 1
fi

# Try CurrentControlSet or ControlSet001
BT_MAC_KEY="$(chntpw -e SYSTEM <<EOF | grep '^  [<]............[>]' | grep -o '[0-9a-f]*'
ls \ControlSet001\Services\BTHPORT\Parameters\Keys
q
EOF
)"

echo
echo "Bluetooth MAC Address: '${BT_MAC_KEY}'"
echo

export BT_MAC_KEY_FILENAME="/var/lib/bluetooth/$(echo "${BT_MAC_KEY}" | tr '[[:lower:]]' '[[:upper:]]' | sed -e 's/../&:/g' -e 's/:$//')"

# List bluetooth devices:
chntpw -e SYSTEM <<EOF
ls \ControlSet001\Services\BTHPORT\Parameters\Keys\\${BT_MAC_KEY}
q
EOF

# #############################################################################
for btdevice in $(chntpw -e SYSTEM <<EOF | grep 'REG_BINARY' | awk '{print $NF}' | egrep -o "[0-9a-f]{12,}"
ls \ControlSet001\Services\BTHPORT\Parameters\Keys\\${BT_MAC_KEY}
q
EOF
)
do

  btdevicekey="$(chntpw -e SYSTEM <<EOF | egrep -o '([0-9A-F]{2} ){16}' | tr -d ' '
hex \ControlSet001\Services\BTHPORT\Parameters\Keys\\${BT_MAC_KEY}\\${btdevice}
q
EOF
)"

  echo "BT DEVICE: '$btdevice'"
  echo "BT DEVICE KEY: '${btdevicekey}'"
  export btdevicefilename="${BT_MAC_KEY_FILENAME}/$(echo "${btdevice}" | tr '[[:lower:]]' '[[:upper:]]' | sed -e 's/../&:/g' -e 's/:$//')"
  sudo ls -l "${btdevicefilename}/info"
  sudo sed -i -e "s/^Key=.*$/Key=${btdevicekey}/" "${btdevicefilename}/info"
  echo
done
# #############################################################################

echo "Run 'sudo systemctl restart bluetooth'..."
