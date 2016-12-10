# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

makeat () {
    # Info: Call configure, make & makeinstall for custom dir/prefix.
    # Rmk: Default prefix is ~/opt/root
    # Syn: {prefix directory}

    mkdir "${1:-${HOME}/opt/root}" 2> /dev/null || return 1

    ./configure --prefix="${1:-${HOME}/opt/root}" && \
        make && \
            make install
}
