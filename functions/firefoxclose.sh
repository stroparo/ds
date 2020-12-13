firefoxclose () {
  if ! which xdotool >/dev/null 2>&1; then
    killall -HUP firefox
    sleep 2
    pidof firefox >/dev/null 2>&1
    return $?
  fi

  FFWID=$(xdotool search --name "Mozilla Firefox" | head -1)
  xdotool windowactivate --sync $FFWID

  # https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly
  xdotool key --clearmodifiers ctrl+q

  sleep 1

  # Confirmation window, if any:
  CWID=$(xdotool search --name "close tabs")
  if [ $? -ne 0 ] && ! pidof firefox >/dev/null 2>&1; then
    return 0
  fi
  xdotool windowactivate --sync $CWID
  xdotool key --clearmodifiers Return

  sleep 2
  ! pidof firefox >/dev/null 2>&1
  return $?
}
