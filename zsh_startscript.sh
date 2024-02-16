#!/bin/bash
cd ~/
## install packages
apt install zsh -y
apt install exa -y
apt install curl -y
## get .zshrc
wget https://raw.githubusercontent.com/KARTOFF8xE/configs/main/.zshrc
## get vivid-Repo
wget "https://github.com/sharkdp/vivid/releases/download/v0.8.0/vivid_0.8.0_amd64.deb"
dpkg -i vivid_0.8.0_amd64.deb
## clone chromatic-zsh
mkdir ~/.zsh_scripts
git clone https://github.com/jimmijj/chromatic-zsh.git ~/.zsh_scripts/chromatic-zsh
## adding plugins
mkdir ~/.zsh_scripts/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh_scripts/plugins/zsh-autosuggestions
## add history
mkdir ~/.cache/zsh
touch ~/.cache/zsh/history
## change login shell
chsh $USER -s $(which zsh)
## start zsh
zsh
