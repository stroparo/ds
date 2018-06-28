# DS - Daily Shells Library

haltsafe () {
  # Info: halts only if any {true,vera}crypt is unmounted correctly.

  typeset crypt_dismounted=true
  typeset crypt_prog=veracrypt

  if which $crypt_prog >/dev/null 2>&1 && \
    $crypt_prog -t -l && \
    ! $crypt_prog -d
  then
    crypt_dismounted=false
  fi

  if ${crypt_dismounted:-false} ; then
    sudo shutdown -h now
  else
    echo "haltsafe: ERROR: $crypt_prog volumes still mounted." 1>&2
    return 1
  fi
}

