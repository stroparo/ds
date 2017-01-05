# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Application installation routines

installapps () {
    # Info: Install applications from the Internet.

    installdropbox
    installexa
    installohmyzsh
    installpowerfonts
    installyoutubedl
}

installatom () {

    if which atom >/dev/null 2>&1 ; then return ; fi

    if _is_cygwin ; then

        wget 'https://atom.io/download/windows'
        mv windows atomsetup.exe
        chmod u+x atomsetup.exe && ./atomsetup.exe && rm -f ./atomsetup.exe

    elif _is_debian || _is_ubuntu ; then

        wget 'https://atom.io/download/deb'
        sudo dpkg -i deb && rm -f deb

    elif _is_redhat ; then

        wget 'https://atom.io/download/rpm'
        sudo rpm -ivh rpm && rm -f rpm
    fi
}

installdropbox () {

    _is_linux || return
    [ -e ~/.dropbox-dist/dropboxd ] && return

    echo '==> Installing dropbox ...' 1>&2

    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | \
        tar xzf -

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
    env DBUS_SESSION_BUS_ADDRESS='' "${HOME}"/.dropbox-dist/dropboxd > /dev/null 2>&1 &
}

installexa () {
    _is_linux || return
    [ ! -d ~/bin ] && ! mkdir ~/bin && return 1
    wget 'https://the.exa.website/releases/exa-0.4-linux-x86_64.zip' || return 1
    unzip 'exa-0.4-linux-x86_64.zip' -d ~/bin || return 1
    rm -f 'exa-0.4-linux-x86_64.zip'
    ln -s 'exa-linux-x86_64' ~/bin/exa
    chmod u+x ~/bin/exa-linux-x86_64
}

installinputfont () {
    # Info: Installs local input font package
    # Syntax: {input-font-package-filename}

    typeset find_command="find \"$HOME/Input_Fonts\" \
\( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
    typeset font_dir="$HOME/.local/share/fonts"
    typeset inputfontpackage="$1"

    _is_linux || return
    [ -e "$font_dir/InputMono-Regular.ttf" ] && return

    echo '==> Installing input font ...' 1>&2
    unzip -d "$HOME" "$inputfontpackage" 'Input_Fonts/*' || return 1
    mkdir -p "$font_dir" 2>/dev/null
    eval $find_command | xargs -0 -I % cp "%" "$font_dir/"
    rm -rf "$HOME/Input_Fonts"
    command -v fc-cache 2>/dev/null && fc-cache -f "$font_dir" # reset font cache
}

installohmyzsh () {
    which zsh >/dev/null || return 1
    [ -d "${HOME}/.oh-my-zsh" ] && return
    echo '==> Installing ohmyzsh ...' 1>&2
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
}

installpowerfonts () {
    _is_linux || return
    [ -e "$HOME/.local/share/fonts/Inconsolata for Powerline.otf" ] && return
    wget https://github.com/powerline/fonts/archive/master.zip -O ~/powerline.zip
    (cd ~ ; unzip powerline.zip)
    echo '==> Installing powerline fonts ...' 1>&2
    ~/fonts-master/install.sh && rm -rf ~/fonts-master ~/powerline.zip
}

installtruecrypt () {
    # Syntax: {package-filename}

    _is_linux || return
    echo "==> Installing ${1##*/} ..." 1>&2
    sudo bash "$pkg"
}

installyoutubedl () {
    ! _is_linux && ! _is_cygwin && return

    typeset youtubedlpath='/usr/local/bin/youtube-dl'
    [ -e "${youtubedlpath}" ] && return

    echo '==> Installing youtube-dl ...' 1>&2

    if _is_linux ; then
        sudo wget -q -O "${youtubedlpath}" 'https://yt-dl.org/latest/youtube-dl'
        sudo chmod a+rx "${youtubedlpath}"
    elif _is_cygwin ; then
        wget -q -O "${youtubedlpath}" 'https://yt-dl.org/latest/youtube-dl'
        chmod a+rx "${youtubedlpath}"
    fi
}

# ##############################################################################

