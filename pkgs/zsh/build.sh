#!/bin/sh
BUILD_DIR="$HOME/bin"
APP_DIR=$BUILD_DIR/apps
pkg="zsh"
mkdir -p "${BUILD_DIR}" $APP_DIR

curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install | sh -s -- -d $APP_DIR/zsh-bin -e no
cd $BUILD_DIR
ln -sf apps/zsh-bin/bin/zsh zsh
tar --mtime="$BUILD_DATE" --sort=name -czf $pkg.tar.gz $pkg apps
echo $pkg done

echo $pkg version
$pkg --version

echo $(which $pkg); ldd $(which $pkg)

echo $APP_DIR/zsh-bin/bin/zsh; ldd $APP_DIR/zsh-bin/bin/zsh
file $APP_DIR/zsh-bin/bin/zsh

du -sh $(which $pkg)
du -sh $APP_DIR/zsh-bin

#./apps/zsh-bin/share/zsh/5.8/scripts/relocate on bin i zsh
