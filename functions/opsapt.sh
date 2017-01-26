# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin APT (aptitude & apt-get) routines

aptaddppa () {
    # Adds ppa repositories listed in the filename argument.
    # Syn: {ppa-list-filename}

    typeset somefail=false

    typeset ppalistfile="$1"
    typeset usage="${pname} {ppa file (one ppa path per line)}"

    sudo which apt-add-repository >/dev/null || return 1

    echo "$ppalistfile" 1>&2
    test -f "$ppalistfile" || return 1

    [[ -n $ZSH_VERSION ]] && set -o shwordsplit

    while read ppa ; do

        if ! (ls -1 /etc/apt/sources.list.d | grep -q "$(echo "$ppa" | sed -e 's#/#-.*#g')")
        then
            elog "ppa '${ppa}' ..."

            if ! sudo apt-add-repository "ppa:${ppa}" ; then
                elog -f "ppa '${ppa}'."
                somefail=true
            fi
        else
            elog -s "ppa '${ppa}' already present."
        fi

    done <<EOF
$(cat "$ppalistfile")
EOF

    [[ -n $ZSH_VERSION ]] && set +o shwordsplit

    if $somefail ; then
        elog -f 'Some ppa failed.'
        return 1
    fi
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
    [[ $- = *i* ]] && $ask && ! userconfirm 'Proceed deploying APT assets?' && return
    [[ $- = *i* ]] && userconfirm 'Upgrade all packages?' && upgradeoption='u'

    aptinstall -${upgradeoption}y "$@"
    fixaptmodes
    aptclean

    if [ -n "$APTREMOVELIST" ] ; then
        sudo aptitude purge $(echo $APTREMOVELIST)
    fi
}

# ##############################################################################

