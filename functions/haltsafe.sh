# DS - Daily Shells Library

haltsafe () {
  # Info: halts only if any {true,vera}crypt is unmounted correctly.

  typeset crypt_dismounted=true
  typeset crypt_prog

  if which truecrypt >/dev/null 2>&1 ; then
    crypt_prog=truecrypt
  elif which veracrypt >/dev/null 2>&1 ; then
    crypt_prog=veracrypt
  else
    echo "haltsafe: FATAL: No crypt program found, aborting safe halt.."
    return 1
  fi

  if ${crypt_prog:-truecrypt} -t -l && ! ${crypt_prog} -d ; then
    crypt_dismounted=false
  fi

  if ${crypt_dismounted:-false} ; then
    sudo shutdown -h now
  else
    echo "haltsafe: ERROR: $crypt_prog volumes still mounted." 1>&2
    return 1
  fi
}

