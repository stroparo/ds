# DS - Daily Shells Library

haltsafe () {
  # Info: halts only if any truecrypt is unmounted correctly.

  typeset tcdismounted=true

  if which truecrypt >/dev/null 2>&1 && \
    truecrypt -t -l && \
    ! truecrypt -d
  then
    tcdismounted=false
  fi

  if ${tcdismounted:-false} ; then
    sudo shutdown -h now
  else
    echo "haltsafe: ERROR: truecrypt volumes still mounted." 1>&2
    return 1
  fi
}

