#!/bin/sh
apk add curl
mkdir -p ~/bin/apps
curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install | sh -s -- -d ~/bin/apps/zsh-bin -e no
cd ~/bin
ln -sf apps/zsh-bin/bin/zsh zsh
tar -cf zsh.tar.gz apps zsh 
#rm -rf apps zsh
#./apps/zsh-bin/share/zsh/5.8/scripts/relocate on bin i zsh
