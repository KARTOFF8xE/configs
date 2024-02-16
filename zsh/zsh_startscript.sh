#!/bin/bash

function exitTrap {
    set +x
}
set -x && trap exitTrap EXIT

if [ "$USER" != root ]; then
    sudo ${0} $USER
    exit
fi
set -e
user=${1}
cd /home/$user
## install packages
apt install zsh -y
apt install exa -y
apt install curl -y
## get .zshrc
wget https://raw.githubusercontent.com/KARTOFF8xE/configs/main/zsh/.zshrc
## get vivid-Repo
wget "https://github.com/sharkdp/vivid/releases/download/v0.8.0/vivid_0.8.0_amd64.deb" -O /tmp/vivid
dpkg -i /tmp/vivid
## clone chromatic-zsh
mkdir -p /home/$user/.zsh_scripts
git clone https://github.com/jimmijj/chromatic-zsh.git /home/$user/.zsh_scripts/chromatic-zsh
## adding plugins
mkdir -p /home/$user/.zsh_scripts/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$user/.zsh_scripts/plugins/zsh-autosuggestions
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh -P /home/$user/.zsh_scripts/plugins/
source /home/$user/.zsh_scripts/plugins/git.plugin.zsh
## add history
mkdir -p /home/$user/.cache/zsh
touch /home/$user/.cache/zsh/history
## change login shell
chsh $user -s $(which zsh)
zsh