#!/bin/sh

mkdir -p ~/bin/apps
curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install | sh -s -- -d ~/bin/apps/zsh-bin -e no
cd ~/bin
ln -sf apps/zsh-bin/bin/zsh zsh
tar -cf zsh.tar.gz apps zsh 
zsh --version
ldd $(which zsh)
file $(which zsh)

ldd apps/zsh-bin/bin/zsh
file apps/zsh-bin/bin/zsh

#rm -rf apps zsh

#./apps/zsh-bin/share/zsh/5.8/scripts/relocate on bin i zsh
