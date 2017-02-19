# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin APT (aptitude & apt-get) routines

if ! which apt >/dev/null 2>&1 \
    && ! which apt-get >/dev/null 2>&1 \
    && ! which aptitude >/dev/null 2>&1
then
    return
fi

aptaddppa () {
    # Adds ppa repositories
    # Syn: {ppa} ...

    sudo which apt-add-repository >/dev/null || return 1

    for ppa in "$@" ; do
        if ! (ls -1 /etc/apt/sources.list.d \
                | grep -q "$(echo "${ppa:-DUMMY}" | sed -e 's#/#-.*#g')")
        then
            sudo apt-add-repository "ppa:${ppa}"
        fi
    done
}

# ##############################################################################
# aptdeploy and helpers

aptinstall () {
    # Installs packages listed in file.
    # Syn: [-u] [-y] filename
    # -u means do upgrade
    # -y means do assume yes (as per vanilla apt)

    typeset assumeyes
    typeset doupdate=true
    typeset doupgrade=false

    typeset oldind="${OPTIND}"
    OPTIND=1
    while getopts ':fuy' option ; do
        case "${option}" in
        f) doupdate=false;;
        u) doupgrade=true;;
        y) assumeyes='-y';;
        esac
    done
    shift $((OPTIND-1)) ; OPTIND="${oldind}"

    ckaptitude || return 1
    if ${doupdate} ; then sudo aptitude update || return 1 ; fi
    if ${doupgrade} ; then sudo aptitude upgrade ${assumeyes} || return 1 ; fi

    if [ -f "$1" ] && [ -s "$1" ] ; then
        sudo aptitude install ${assumeyes} -Z $(sed -e 's/#.*$//' "$@" | grep .)
    elif [[ $1 != dummy ]] ; then
        sudo aptitude install ${assumeyes} -Z "$@"
    fi
}

fixaptmodes () {
    # Fix workaround for /etc/apt/sources.list.d mode issue.
    #   This will sudo chmod 644 to all files in /etc/apt/sources.list.d
    # Rmk:
    #   Common scenario this glitch happens is a call to update after adding a ppa repo.

    if [ -d /etc/apt/sources.list.d ] ; then
        sudo chmod 644 /etc/apt/sources.list.d/*
    fi
}

aptclean () {
    # Cleans up ubuntu packages and unwanted files.
    # Rmk - this also installs localepurge, but it must be executed separately (in that
    #   package you will choose only the locales you use and/or want to keep).

    ckapt || return "$?"
    which deborphan > /dev/null 2>&1 || sudo aptitude install -y deborphan
    which localepurge > /dev/null 2>&1 || sudo aptitude install -y localepurge

    if which deborphan > /dev/null 2>&1 ; then
        echo '==> Orphaned packages:'
        sudo deborphan
        if userconfirm 'Remove?' ; then
            sudo deborphan | xargs sudo apt-get purge -y
        fi
    else
        elog -s -p "$pname" "No deborphan program available.."
    fi

    # Remove caches:
    userconfirm 'apt-get autoclean?' && sudo apt-get autoclean -y
    userconfirm 'apt-get clean?' && sudo apt-get clean -y

    elog '==> Complete.'
}

aptdeploy () {
    # Installs apt packages using the routines: aptinstall, fixaptmodes, aptclean.
    # Deps: apt or apt-get.
    # Rmk: APTREMOVELIST global will cause aptitude purge to be called with that list.

    typeset ask=false
    typeset upgradeoption

    [[ $1 = -i ]] && ask=true && shift

    ckapt || return "$?"
    _any_not_r "$@" && return 1
    [[ $- = *i* ]] && $ask && ! userconfirm "Proceed deploying APT lists ($*)?" && return
    [[ $- = *i* ]] && userconfirm 'Upgrade all packages?' && upgradeoption='u'

    aptinstall -${upgradeoption}y "$@"
    fixaptmodes
    aptclean

    if [ -n "$APTREMOVELIST" ] ; then
        sudo aptitude purge $(echo $APTREMOVELIST)
    fi
}

# ##############################################################################
# dpkg

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

# ##############################################################################

