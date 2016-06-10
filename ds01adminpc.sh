# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Admin & ops functions most convenient for a local PC or workstation

# ##############################################################################
# Installations

unset installdropbox
installdropbox () {
    typeset pname=installdropbox

    if _is_linux && [ ! -e ~/.dropbox-dist/dropboxd ] ; then
        elog -n "$pname" 'Started.'

        cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

        # Desktop tray workaround (export empty DBUS_SESSION_BUS_ADDRESS for process):
        # This first approach doesnt work as Dropbox often updates itself:
        # sed -i -e 's/^exec.*dropbox/export DBUS_SESSION_BUS_ADDRESS=""; &/' ~/.dropbox-dist/dropboxd
        cat > ~/.config/autostart/dropbox.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=dropbox
Comment=dropbox
Exec=env DBUS_SESSION_BUS_ADDRESS='' ${HOME}/.dropbox-dist/dropboxd
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF
        elog -n "$pname" 'Launching dropbox..'
        env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &

        elog -n "$pname" 'Completed.'
    else
        elog -n "$pname" -s 'Already installed or not in Linux.'
    fi
}

# Function installinputfont - Installs local input font package
# Syntax: {input-font-package-filename}
unset installinputfont
installinputfont () {
    typeset pname=installinputfont
    typeset find_command="find \"$HOME/Input_Fonts\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
    typeset font_dir="$HOME/.local/share/fonts"
    typeset inputfontpackage="$1"

    if ! _is_linux ; then
        elog -f -n $pname 'Only Linux supported.'
        return 1
    fi

    if [ ! -e  "$inputfontpackage" ] ; then
        elog -f -n $pname 'Invalid input font package location (first argument).'
        return 1
    fi

    unzip -d "$HOME" "$inputfontpackage" 'Input_Fonts/*'
    test -d "$font_dir" || mkdir -p "$font_dir"
    eval $find_command | xargs -0 -I % cp "%" "$font_dir/"
    rm -rf "$HOME/Input_Fonts"

    # Reset font cache on Linux
    if command -v fc-cache @>/dev/null ; then
        elog -n $pname "Resetting font cache, this may take a moment..."
        fc-cache -f $font_dir
    fi

    elog -n $pname "Finished installing fonts to '$font_dir'."
}

# Function installpowerfonts - Install powerline fonts.
unset installpowerfonts
installpowerfonts () {
    echo '==> Installing powerline fonts..' 1>&2

    if _is_linux ; then

        # TODO unless installed:

        wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
        (cd ~ ; unzip powerline.zip)
        ~/fonts-master/install.sh && rm -rf ~/fonts-master ~/powerline.zip
    fi
}

# Function installyoutubedl
unset installyoutubedl
installyoutubedl () {
    typeset pname=installyoutubedl
    typeset youtubedlpath='/usr/local/bin/youtube-dl'

    echo '==> Installing youtube-dl..' 1>&2

    if _is_linux ; then
        if [ ! -e "${youtubedlpath}" ] ; then
            sudo wget 'https://yt-dl.org/latest/youtube-dl' -O "${youtubedlpath}"
            sudo chmod a+rx "${youtubedlpath}"
        else
            echo 'Already installed.' 1>&2
        fi
    else
        echo 'Not in Linux, so nothing done.' 1>&2
    fi
}

# ##############################################################################
# Virtualbox

# Function mountvboxsf - Mount virtualbox shared folder.
# Syntax: path-to-dir (sharing will be named as its basename)
unset mountvboxsf
mountvboxsf () {

    [ -n "${1}" ] || return 1
    [ -d "${1}" ] || sudo mkdir "${1}"

    sudo mount -t vboxsf -o rw,uid="${USER}",gid="$(id -gn)" "$(basename ${1})" "${1}"

    if [ "$?" -eq 0 ] ; then
        cd "${1}"
        pwd
        ls -FlA
    fi
}

# ##############################################################################

