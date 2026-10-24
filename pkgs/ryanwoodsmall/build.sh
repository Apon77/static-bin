#!/bin/sh
#set -eux

BUILD_DIR="$HOME/bin"
URL="https://github.com/ryanwoodsmall/static-binaries/raw/refs/heads/master/x86_64"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

pkgs="ag bash busybox ccache coreutils curl dash dropbearmulti jq less links make mk nc pv rc rsync screen socat sslh stunnel tini tmux toybox unrar xml xz"
pkgs="ag"
for pkg in $pkgs; do
  curl -fsSL "${URL}/${pkg}" -o "${BUILD_DIR}/${pkg}"
  chmod +x "${BUILD_DIR}/${pkg}"
  tar --mtime="$BUILD_DATE" --sort=name -czf $pkg.tar.gz $pkg
  echo $pkg done
done

for pkg in $pkgs; do
  echo $pkg version
  $pkg --version 
done

for pkg in $pkgs; do
  echo $(which $pkg); ldd $(which $pkg)
done

for pkg in $pkgs; do
  du -sh $(which $pkg)
done

#gh release upload v1.0.0 *tar.gz --clobber --repo apon77/static-bin
