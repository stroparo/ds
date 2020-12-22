export FILEMGR=thunar

if ! which "${FILEMGR}" >/dev/null 2>&1 ; then
  if which nautilus ; then
    export FILEMGR=nautilus
  elif which dolphin ; then
    export FILEMGR=dolphin
  elif which pcmanfm ; then
    export FILEMGR=pcmanfm
  fi
fi
