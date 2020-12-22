validpkgs () {
  typeset pkg_list_filename="${1}"
  typeset pkg_list="$(sed -e 's/ *#.*$//' "${pkg_list_filename}" | tr '\n' ' ')"
  typeset cmd="${2}"

  for pkg in $(echo ${pkg_list}) ; do
    if $(echo ${cmd}) "${pkg}" >/dev/null 2>&1 ; then
      echo "${pkg}"
    fi
  done \
  | tr -s '\n' ' '
}

validpkgsapt () {
  typeset pkg_list_filename="${1}"
  typeset cmd="apt-cache show"
  validpkgs "${pkg_list_filename}" "${cmd}"
}

validpkgsrpm () {
  typeset pkg_list_filename="${1}"
  typeset cmd="yum info"
  validpkgs "${pkg_list_filename}" "${cmd}"
}
