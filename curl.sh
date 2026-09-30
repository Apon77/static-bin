#!/bin/sh
# Pinning the base container to a verified stable Alpine version
docker run -i --rm -v "$PWD":/out -w /root alpine:3.24.2 /bin/sh -s <<'EOF'
# Install archive download and extraction tools (xz is required to open .tar.xz)
apk update
apk add wget tar xz

# 1. Fetch the precompiled static curl 8.22.0 musl release archive
cd /tmp
wget https://github.com/stunnel/static-curl/releases/download/8.22.0/curl-linux-x86_64-musl-8.22.0.tar.xz


# 2. Extract into a clean target space
mkdir -p /tmp/extracted-curl
tar -xf curl-linux-x86_64-musl-8.22.0.tar.xz -C /tmp/extracted-curl

# 3. Copy the raw binary directly out to the host directory and match ownership
cp /tmp/extracted-curl/curl /out/curl
chmod +x /out/curl
chown $(id -u):$(id -g) /out/curl
EOF

