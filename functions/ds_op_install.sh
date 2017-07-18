# DS - Daily Shells Library
# License:
#  See README.md document in projects page at
#  https://github.com/stroparo/ds

# ##############################################################################
# Application installation routines

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
    ls -1d ~/bin/exa >/dev/null 2>&1 && return
    [ ! -d ~/bin ] && ! mkdir ~/bin && return 1
    wget 'https://the.exa.website/releases/exa-0.4-linux-x86_64.zip' || return 1
    mv 'exa-0.4-linux-x86_64.zip' /tmp/
    unzip '/tmp/exa-0.4-linux-x86_64.zip' -d ~/bin
    rm -f '/tmp/exa-0.4-linux-x86_64.zip'
    ln -s exa-linux-x86_64 ~/bin/exa
    chmod u+x ~/bin/exa-linux-x86_64
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

# ##############################################################################

