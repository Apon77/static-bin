#!/bin/sh
# Pinning the base container to a verified stable Alpine version
docker run -i --rm -v "$PWD":/out -w /root alpine:3.24.2 /bin/sh -s <<'EOF'
# Install compiler, dependencies, and archive generation tools
apk update
apk add build-base openssl-dev openssl-libs-static zlib-dev zlib-static linux-headers wget tar

# 1. Download and extract the OpenSSH 10.5 portable archive
wget https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.5p1.tar.gz
tar -xzf openssh-10.5p1.tar.gz
cd openssh-10.5p1

# 2. Configure compile layout targeting musl static linking components
./configure \
    CFLAGS="-static" \
    LDFLAGS="-static" \
    --without-openssl-header-check \
    --disable-shared

# 3. Build and strip all binaries including scp
make -j$(nproc)
strip sshd ssh scp ssh-keygen ssh-keyscan ssh-agent ssh-add sftp sftp-server

# 4. Assemble the standalone portable directory structure
mkdir -p /tmp/openssh/bin /tmp/openssh/etc

# Copy all compiled binaries
cp sshd ssh scp ssh-keygen ssh-keyscan ssh-agent ssh-add sftp sftp-server /tmp/openssh/bin/

# Copy default configurations and the ssh-copy-id shell helper
cp sshd_config ssh_config /tmp/openssh/etc/
cp contrib/ssh-copy-id /tmp/openssh/bin/
chmod +x /tmp/openssh/bin/ssh-copy-id

# 5. Save file permissions and copy the compressed archive to the host as 'openssh.tar.gz'
cd /tmp
tar -czf /out/openssh.tar.gz openssh
chown -R $(id -u):$(id -g) /out/openssh.tar.gz
EOF

