zddsbak () { d "${DS_ENV_BAK}" ; }
zddslog () { cd "${DS_ENV_LOG}" && ls -AFlrt ; }
zddslogrev () { cd "${DS_ENV_LOG}" && cd "$(ls -1d */|sort|tail -n 1)" && ls -AFlrt ; }
zddslogtail () { cd "${DS_ENV_LOG}" && (ls -AFlrt | tail -n 64) ; }
zddslogtoday () { cd "${DS_ENV_LOG}" && (ls -AFlrt | grep "$(date +"%b %d")") ; }
zdtemp () { d "${TEMP_DIRECTORY}" ; }
