# Daily Shells Stroparo extensions

# Wrappers for gitr script from the Daily Shells library (stroparo/ds)

# Linux vs non-Linux options for gitr.sh:
if (uname -a | grep -i -q linux) ; then
  export GITR_PARALLEL=true
else
  export GITR_VERBOSE_OPTION=v
fi

# Branch
rbranch () { gitr.sh -fv -- branch -avv | egrep -- "^(==|---)|${1}" ; }
rcheckedout () { gitr.sh -fv -- branch "$@" | egrep -- "^(==|---)|^[*]" ; }

radd    ()  { GITR_PARALLEL=false gitr.sh -f  -- add -A "$@" ; gitr.sh -fv status -s ; }
rci     ()  { GITR_PARALLEL=false gitr.sh -fv -- commit -m "'$@'" ; }
rco     ()  { GITR_PARALLEL=false gitr.sh -fv -- checkout "$@" ; }
rdca    ()  { GITR_PARALLEL=false gitr.sh -f  -- diff --cached "$@" ; }
rfetch  ()  { gitr.sh -f${GITR_VERBOSE_OPTION} -- fetch "$@" ; }
rfetchallp () { gitr.sh -f${GITR_VERBOSE_OPTION} -- fetch --all -p "$@" ; }
rpull   ()  { gitr.sh -f${GITR_VERBOSE_OPTION} -- pull "$@" ; }
rpush   ()  { gitr.sh -f${GITR_VERBOSE_OPTION} -- push "$@" ; }
rpushmirror () { gitr.sh -fv push mirror ${1:-master} | egrep -v "fatal:|make sure|repository exists|^$" ; }
rss     ()  { gitr.sh -f${GITR_VERBOSE_OPTION} -- status -s "$@" ; }

# Compound commands
rpushcurrent () { rpush origin HEAD ; rpushmirror HEAD ; rss ; }
rpushmatching () { rpush origin : ; rpushmirror : ; rss ; }
rsyncmaster () { rco master && rpull origin master && rpush origin master && rpushmirror master ; rss ; }
