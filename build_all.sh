#!/usr/bin/env bash
#apt install --no-install-recommends curl ca-certificates file git gh
set -euo pipefail

PATH=$HOME/bin:$PATH
export RELEASE_TAG="v1.0.0"
export BUILD_DATE="2026-10-04 00:00:00Z"
 #export GH_TOKEN="github_pat_*****" run in terminal manually with space before it, if using act use in .env

./pkgs/zsh/build.sh
./pkgs/ngrok/build.sh
./pkgs/ryanwoodsmall/build.sh

cd $HOME/bin
ls -lah *tar.gz
sha256sum *.tar.gz
ls -p1 | grep -v 'tar.gz$' | grep -v '/$' | xargs file

