# Daily Shells Library

# #############################################################################
# Filesystem testing routines

_all_dirs_r () {
  for i in "$@" ; do [ ! -d "${1}" -o ! -r "${1}" ] && return 1 ; done ; return 0
}
_all_dirs_rwx () {
  # Tests if any of the directory arguments are neither readable nor w nor x.
  for i in "$@" ; do
    if [ ! -d "${1}" -o ! -r "${1}" -o ! -w "${1}" -o ! -x "${1}" ] ; then
      return 1
    fi
  done
  return 0
}
_all_dirs_w () {
  for i in "$@" ; do [ ! -d "${1}" -o ! -w "${1}" ] && return 1 ; done ; return 0
}
_all_exist () {
  for i in "$@" ; do [ ! -e "${1}" ] && return 1 ; done ; return 0
}
_all_not_null () {
  for i in "$@" ; do [ -z "${i}" ] && return 1 ; done ; return 0
}
_all_r () {
  for i in "$@" ; do [ ! -r "${1}" ] && return 1 ; done ; return 0
}
_all_w () {
  for i in "$@" ; do [ ! -w "${1}" ] && return 1 ; done ; return 0
}
_any_dir_not_r () {
  ! _all_dirs_r "$@"
}
_any_dir_not_rwx () {
  ! _all_dirs_rwx "$@"
}
_any_dir_not_w () {
  ! _all_dirs_w "$@"
}
_any_exists () {
  for i in "$@" ; do [ -e "${1}" ] && return 0 ; done ; return 1
}
_any_not_exists () {
  ! _all_exist "$@"
}
_any_not_r () {
  ! _all_r "$@"
}
_any_not_w () {
  ! _all_w "$@"
}
_any_null () {
  for i in "$@" ; do [ -z "${i}" ] && return 0 ; done ; return 1
}

# #############################################################################
# Operating System tests

_is_debian_family () { egrep -i -q -r 'debian|ubuntu' /etc/*release ; }
_is_debian () { egrep -i -q -r 'debian' /etc/*release ; }
_is_ubuntu () { egrep -i -q -r 'ubuntu' /etc/*release ; }

_is_el_family () { egrep -i -q -r '(cent.?os|oracle|red.?hat|enterprise|rhel|fedora)' /etc/*release ; }
_is_el () { egrep -i -q -r '(cent.?os|oracle|red.?hat|enterprise|rhel)' /etc/*release ; }
_is_el6 () { egrep -i -q -r '(cent.?os|oracle|red.?hat|enterprise|rhel).* 6' /etc/*release ; }
_is_el7 () { egrep -i -q -r '(cent.?os|oracle|red.?hat|enterprise|rhel).* 7' /etc/*release ; }
_is_fedora () { egrep -i -q -r 'fedora' /etc/*release ; }
