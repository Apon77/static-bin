# Pinning the base container to a verified stable Alpine version
docker run -i --rm -v "$PWD":/out -w /root alpine:3.24.2 /bin/sh -s <<EOF
# Install compiler and package download tools
apk add gcc make musl-dev ncurses-static wget

# 1. Download and extract your specified v9.2.1144 release archive
wget https://github.com/vim/vim/archive/refs/tags/v9.2.1144.tar.gz
tar -xf v9.2.1144.tar.gz
cd vim-9.2.1144

# 2. Configure compile layout targeting musl static linking components
LDFLAGS="-static" ./configure \
  --disable-channel \
  --disable-gpm \
  --disable-gtktest \
  --disable-gui \
  --disable-netbeans \
  --disable-nls \
  --disable-selinux \
  --disable-smack \
  --disable-sysmouse \
  --disable-xsmp \
  --enable-multibyte \
  --with-features=normal \
  --without-x \
  --with-tlib=ncursesw

make -j$(nproc)
strip src/vim

# 3. Save file permissions and copy out to the host directory as 'vim'
cp src/vim /out/vim
chown -R $(id -u):$(id -g) /out/vim
EOF

