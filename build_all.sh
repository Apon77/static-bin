#!/usr/bin/env bash
#apt install --no-install-recommends curl ca-certificates file
set -euo pipefail

PATH=$HOME/bin:$PATH
RELEASE_TAG="v1.0.0"
BUILD_DATE="2026-10-04 00:00:00Z"

#./pkgs/zsh/build.sh
#./pkgs/ngrok/build.sh
./pkgs/ryanwoodsmall/build.sh
