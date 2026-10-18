#!/bin/sh

BUILD_DIR="$HOME/bin"
mkdir -p "${BUILD_DIR}"

curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C "${BUILD_DIR}"

cd ~/bin
tar -cf ngrok.tar.gz ngrok
ngrok --version
ldd $(which ngrok)
file $(which ngrok)
