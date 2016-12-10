# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

dpkgstat () {
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

