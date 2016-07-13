# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin APT (aptitude & apt-get) functions

# Function ckaptitude - checks and installs aptitude if unavailable.
unset ckaptitude
ckaptitude () {
    typeset pname=ckaptitude

    if ! which aptitude > /dev/null 2>&1 ; then
        elog -n "$pname" 'Installing aptitude..'

        sudo apt-get update \
        && sudo apt-get install -y aptitude 

        if ! which aptitude > /dev/null 2>&1 ; then
            elog -n "$pname" -f 'Failed installing aptitude. Aborted.'
            return 1
        fi
        elog -n "$pname" 'Check complete.'
    fi
}

# Function aptclean - clean up ubuntu packages and unwanted files.
# Rmk - this also installs localepurge, but it must be executed separately (in that
#   package you will choose only the locales you use and/or want to keep).
unset aptclean
aptclean () {
    typeset pname=aptclean
    typeset rmorphan

    elog -n "$pname" 'Started.'

    ckaptitude || return 1
    sudo aptitude update || return 2

    which deborphan > /dev/null 2>&1 || sudo aptitude install -y deborphan
    which localepurge > /dev/null 2>&1 || sudo aptitude install -y localepurge

    # Remove bulky stock packages:
    sudo aptitude purge -y oxygen-icon-theme

    # Remove orphaned packages:
    if which deborphan > /dev/null 2>&1 ; then
        elog -n "$pname" '...'
        elog -n "$pname" 'Orphaned packages:'
        sudo deborphan
        elog -n "$pname" 'Remove? (y|n) '
        read rmorphan
        if [[ ${rmorphan} = y* ]] ; then
            sudo deborphan | xargs sudo apt-get purge -y
        fi
    fi

    # Remove caches:
    sudo apt-get autoclean -y
    sudo apt-get clean -y

    elog -n "$pname" 'Completed.'
}

# Function aptinstall - Install packages listed in file.
# Syntax: [-u] [-y] filename
# Syntax description:
# -u means do upgrade
# -y means do assume yes (as per vanilla apt)
unset aptinstall
aptinstall () {
    typeset oldind="${OPTIND}"
    typeset assumeyes doupgrade pkgslist

    OPTIND=1
    while getopts ':uy' option ; do
        case "${option}" in
        u) doupgrade=true;;
        y) assumeyes='-y';;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"
  
    # Prep:

    if [ ! -r "${1}" ] ; then
        echo "A readable packagelist file must be passed as the first argument. Aborted." 1>&2
        return 1
    fi
    ckaptitude || return 1
    sudo aptitude update || return 2

    pkgslist=$(sed -e 's/#.*$//' "${1}" | grep .)

    # Main task:
  
    if ${doupgrade:-false} ; then
        sudo aptitude upgrade ${assumeyes} || return 11
    fi

    [[ -n $ZSH_VERSION ]] && set -o shwordsplit
    sudo aptitude install ${assumeyes} -Z ${pkgslist} || return 21
    [[ -n $ZSH_VERSION ]] && set +o shwordsplit
}

# Function dpkgstat: View installation status of given package names.
# Deps: bash and debian based dpkg command.
# Output: dpkg -s output filtered by '^Package:|^Status:'
# Syntax: {pkg1} {pkg2} ... {pkgN}
unset dpkgstat
dpkgstat () {
    typeset usage='Syntax: ${0} {pkg1} {pkg2} ... {pkgN}'

    [ "${#}" -lt 1 ] && echo "${usage}" && return 1

    dpkg -s "$@" | \
    awk '
        /^Package:/ { pkg = $0; }
        /^Status:/ {
            stat = $0; printf("%-32s%s\n", pkg, stat);
        }'
}

# Function fixaptmodes - Fix workaround for /etc/apt/sources.list.d mode issue.
#   This will sudo chmod 644 to all files in /etc/apt/sources.list.d
# Rmk: Common scenario this glitch happens is a call to update after adding a ppa repo.
unset fixaptmodes
fixaptmodes () {
    if [ -d /etc/apt/sources.list.d ] ; then
        sudo chmod 644 /etc/apt/sources.list.d/*
    fi
}

# Function installppa - add ubuntu ppa repositories.
unset installppa
installppa () {

    typeset pname=installppa

    typeset somefail=false
    typeset ppalistfile="$1"
    typeset usage="${pname} {ppa file (one ppa path per line)}"

    ! _is_ubuntu && elog -f -n "$pname" "Not in ubuntu." && return 1

    [ ! -f "$ppalistfile" ] && elog -f -n "$pname" "${usage}" && return 1

    elog -n "$pname" 'Started.'

    [[ -n $ZSH_VERSION ]] && set -o shwordsplit

    for ppa in "$(cat "$ppalistfile")" ; do

        if ! (ls -1 /etc/apt/sources.list.d | \
            grep -q "$(echo "$ppa" | sed -e 's#/#-#g')")
        then
            elog -n "$pname" "Adding ppa: ${ppa}"

            if ! sudo apt-add-repository "ppa:${ppa}" ; then
                elog -f -n "$pname" "Failed installing '${ppa}' ppa."
                somefail=true
            fi
        else
            elog -s -n "$pname" "'${ppa}' ppa already present."
        fi

    done

    [[ -n $ZSH_VERSION ]] && set +o shwordsplit

    if $somefail ; then
        elog -f -n "$pname" 'Some ppa failed.'
        return 1
    else
        elog -n "$pname" 'Complete.'
    fi
}

