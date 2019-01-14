# Daily Shells Library
# More instructions and licensing at:
# https://github.com/stroparo/ds

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
