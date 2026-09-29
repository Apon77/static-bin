#!/bin/sh
# Pinning the base container to a verified stable Alpine version
docker run -i --rm -v "$PWD":/out -w /root alpine:3.24.2 /bin/sh -s <<'EOF'
# Install compiler, dependencies, and archive generation tools
apk update
apk add cmake gcc gettext-dev gettext-static git gperf build-base \
  libtermkey-dev libuv-dev libuv-static libvterm-dev libvterm-static \
  lua-lpeg-dev lua-luv-dev lua-luv-static lua-mpack lua5.1-bitop \
  lua5.1-lpeg luajit-dev msgpack-c-dev musl-dev samurai \
  tree-sitter-dev tree-sitter-static unibilium-dev linux-headers wget tar

# 1. Download and extract your specified v0.12.5 release archive
wget https://github.com/neovim/neovim/archive/refs/tags/v0.12.5.tar.gz
tar -xf v0.12.5.tar.gz
cd neovim-0.12.5

# 2. Build local dependencies safely by unsetting global compiler flags
unset CFLAGS
unset LDFLAGS
make deps

# 3. Configure compile layout targeting musl static linking components
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="-static" \
  -DCMAKE_SHARED_LINKER_FLAGS="-static" \
  -DLIBINTL_LIBRARY=/usr/lib/libintl.a

cmake --build build --config Release
strip build/bin/nvim

# 4. Assemble the standalone portable configuration directory structure
mkdir -p /tmp/nvim/bin /tmp/nvim/share
cp build/bin/nvim /tmp/nvim/bin/
cp -r runtime /tmp/nvim/share/nvim

# 5. Inject the automatic path runner wrapper script inside the bundle
cat << 'INNER_EOF' > /tmp/nvim/nvim
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
VIMRUNTIME="$DIR/share/nvim" exec "$DIR/bin/nvim" "$@"
INNER_EOF
chmod +x /tmp/nvim/nvim

# 6. Save file permissions and copy the compressed archive to the host as 'nvim.tar.gz'
cd /tmp
tar -czf /out/nvim.tar.gz nvim
chown -R $(id -u):$(id -g) /out/nvim.tar.gz
EOF

