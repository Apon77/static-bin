#!/bin/sh

BUILD_DIR="$HOME/bin"
pkg="ngrok"
mkdir -p "${BUILD_DIR}"

curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C "${BUILD_DIR}"

cd ~/bin
tar --mtime="$BUILD_DATE" --sort=name -czf $pkg.tar.gz $pkg
echo $pkg done
echo $pkg version
$pkg --version
echo $(which $pkg); ldd $(which $pkg)
du -sh $(which $pkg)
