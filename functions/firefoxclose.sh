# firefoxclose () - similar to stroparo/ds' windowclose (), adapted to Firefox.
firefoxclose () {
  typeset process_expr="firefox"
  typeset window_expr="Mozilla Firefox"
  typeset close_shortcut="ctrl+q"

  if ! which xdotool >/dev/null 2>&1; then
    killall -HUP "${process_expr}"
    timeoutprocessclose.sh "${process_expr}"
    return $?
  fi

  WINDOW_ID="$(xdotool search --name "${window_expr}" | head -1)"
  xdotool windowactivate --sync "${WINDOW_ID}"
  xdotool key --clearmodifiers "${close_shortcut}"

  # Confirmation window, if any:
  sleep 2
  CWID="$(xdotool search --name "close tabs")"
  if [ $? -ne 0 ] && ! pidof "${process_expr}" >/dev/null 2>&1; then
    return 0
  fi
  if [ -n "$CWID" ] ; then
    xdotool windowactivate --sync "${CWID}"
    xdotool key --clearmodifiers Return
    sleep "${timeout}"
  fi

  timeoutprocessclose.sh "${process_expr}"
  return $?
}
