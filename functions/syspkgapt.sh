# DRYSL (DRY Scripting Library)
# More instructions and licensing at:
# https://github.com/stroparo/ds


aptcleanup () {
  echo "${PROGNAME:-aptcleanup()}: INFO: APT repository clean up (autoremove & clean)..."
  sudo "$APTPROG" autoremove -y
  sudo "$APTPROG" clean -y
}


aptflatpak () {
  if ! type flatpak >/dev/null 2>&1 ; then
    sudo apt-get update \
    && sudo apt-get install flatpak \
    && flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}


aptpkgstat () {
  # Info: Displays installation status of given package names
  # Syn: {pkg1} {pkg2} ... {pkgN}

  [ "${#}" -lt 1 ] && return 1

  dpkg -s "$@" | \
    awk '
      /^Package:/ { pkg = $0; }
      /^Status:/ {
        stat = $0; printf("%-32s%s\n", pkg, stat);
      }
    '
}
