runr () {
  if [ -f ~/.runr/entry.sh ] ; then
    [ -x ~/.runr/entry.sh ] || chmod 755 ~/.runr/entry.sh
    ~/.runr/entry.sh -p "$@"
  else
    bash -c "$(curl -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
      || curl -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
      entry.sh "$@"
  fi
}

runrnopreserve () {
  if [ -f ~/.runr/entry.sh ] ; then
    [ -x ~/.runr/entry.sh ] || chmod 755 ~/.runr/entry.sh
    ~/.runr/entry.sh "$@"
  else
    bash -c "$(curl -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
      || curl -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
      entry.sh "$@"
  fi
}
