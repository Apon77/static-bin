#!/usr/bin/env bash
set -euo pipefail

RELEASE_TAG="v1.0.0"
BUILD_DATE="2026-10-04 00:00:00Z"

./pkgs/zsh/build.sh

which zsh
