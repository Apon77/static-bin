#!/usr/bin/env bash
set -euo pipefail

RELEASE_TAG="v1.0.0"
BUILD_DATE="2026-10-04 00:00:00Z"

# Output configuration
BUILD_DIR="out"
CHECKSUM_FILE="${BUILD_DIR}/checksums.txt"

RYANWOODSMALL_URL="https://github.com/ryanwoodsmall/static-binaries/raw/refs/heads/master/x86_64"
RYANWOODSMALL_BIN=(
    ag
    bash
    busybox
    ccache
    coreutils
    curl
    dash
    dropbearmulti
    jq
    less
    links
    make
    mk
    nc
    pv
    rc
    rsync
    screen
    socat
    sslh
    stunnel
    tini
    tmux
    toybox
    unrar
    xml
    xz
)

EXPLICIT_PKGS=(aria2 neovim ngrok tailscale vim)
ALL_PKGS=("${EXPLICIT_PKGS[@]}" "${RYANWOODSMALL_BIN[@]}")

# Ensure the output directory exists
mkdir -p "${BUILD_DIR}"

# Function equivalent to 'define pack'
pack() {
    local target="$1"
    local file_or_dir="${2:-$target}"

    (
        cd "${BUILD_DIR}"
        tar --sort=name \
            --mtime="${BUILD_DATE}" \
            --owner=0 --group=0 --numeric-owner \
            --use-compress-program="pigz -n -k -6" \
            -cf "${target}.tar.gz" "${file_or_dir}"

        shasum -a 256 "${target}.tar.gz" >> "checksums.txt"
        rm -rf "${file_or_dir}"
    )
    echo "---------------------------${target} completed--------------------"
}

# --- Target Commands ---

init_checksums() {
    > "${CHECKSUM_FILE}"
}

build_aria2() {
    curl -fsSL https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -xz -C "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}/aria2/bin"
    mv "${BUILD_DIR}/aria2c" "${BUILD_DIR}/aria2/bin/"
    pack "aria2"
}

build_neovim() {
    curl -fsSL https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz | tar -xz -C "${BUILD_DIR}"
    mv "${BUILD_DIR}"/nvim* "${BUILD_DIR}/neovim"
    pack "neovim"
}

build_ngrok() {
    curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C "${BUILD_DIR}"
    pack "ngrok"
}

build_tailscale() {
    curl -fsSL https://pkgs.tailscale.com/stable/tailscale_1.102.4_amd64.tgz | tar -xz -C "${BUILD_DIR}"
    mv "${BUILD_DIR}"/tailscale_* "${BUILD_DIR}/tailscale"
    pack "tailscale"
}

build_vim() {
    curl -fsSL https://github.com/heywoodlh/vim-builds/releases/download/9.2/vim-x86_64 -o "${BUILD_DIR}/vim"
    chmod +x "${BUILD_DIR}/vim"
    pack "vim"
}

build_ryanwoodsmall_bin() {
    local pkg="$1"
    curl -fsSL "${RYANWOODSMALL_URL}/${pkg}" -o "${BUILD_DIR}/${pkg}"
    chmod +x "${BUILD_DIR}/${pkg}"
    pack "${pkg}"
}

build_all() {
    init_checksums

    build_aria2
    build_neovim
    build_ngrok
    build_tailscale
    build_vim

    for bin in "${RYANWOODSMALL_BIN[@]}"; do
        build_ryanwoodsmall_bin "${bin}"
    done
    verify
}

verify() {
    if [ -f "${CHECKSUM_FILE}" ]; then
        (
            cd "${BUILD_DIR}"
            shasum -a 256 -c "checksums.txt"
        )
    else
        echo "No ${CHECKSUM_FILE} found."
    fi
    echo "---------------------------verify completed--------------------"
}

clean() {
    rm -rf "${BUILD_DIR}"
    echo "Cleaned ${BUILD_DIR} directory."
}

# --- CLI Router ---

case "${1:-all}" in
    all)
        build_all
        ;;
    init-checksums)
        init_checksums
        ;;
    aria2)
        build_aria2
        ;;
    neovim)
        build_neovim
        ;;
    ngrok)
        build_ngrok
        ;;
    tailscale)
        build_tailscale
        ;;
    vim)
        build_vim
        ;;
    ryan)
        for bin in "${RYANWOODSMALL_BIN[@]}"; do
            build_ryanwoodsmall_bin "${bin}"
        done
        ;;
    verify)
        verify
        ;;
    clean)
        clean
        ;;
    *)
        for bin in "${RYANWOODSMALL_BIN[@]}"; do
            if [ "$1" = "${bin}" ]; then
                build_ryanwoodsmall_bin "${bin}"
                exit 0
            fi
        done
        echo "Unknown target: $1"
        exit 1
        ;;
esac
