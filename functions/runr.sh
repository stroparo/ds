runr () {
  typeset ignore_ssl_option
  typeset script_content

  if ${IGNORE_SSL:-false} ; then
    ignore_ssl_option='-k'
  fi

  if [ -f ~/.runr/entry.sh ] ; then
    script_content="$(cat ~/.runr/entry.sh)"
    bash -c "${script_content}" entry.sh "$@"
  else
    bash -c "$(curl ${ignore_ssl_option} -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
      || curl ${ignore_ssl_option} -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
      entry.sh "$@"
  fi
}

runru () {

  typeset ignore_ssl_option

  if ${IGNORE_SSL:-false} ; then
    ignore_ssl_option='-k'
  fi

  mv ~/.runr ~/.runr.$(date '+%Y%m%d-%OH%OM%OS') || return $?

  bash -c "$(curl ${ignore_ssl_option} -LSf "https://bitbucket.org/stroparo/runr/raw/master/entry.sh" \
    || curl ${ignore_ssl_option} -LSf "https://raw.githubusercontent.com/stroparo/runr/master/entry.sh")" \
    entry.sh "$@"
}
