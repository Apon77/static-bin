#!/bin/sh
# Pinning the base container to a verified stable Alpine version
docker run -i --rm -v "$PWD":/out -w /root alpine:3.24.2 /bin/sh -s <<'EOF'
# Install wget to fetch the binary
apk update
apk add wget tar

# 1. Fetch the raw static busybox binary directly
cd /tmp
wget https://github.com/shutingrz/busybox-static-binaries-fat/raw/refs/heads/main/busybox-x86_64-linux-gnu

# 2. Assemble the standalone portable configuration directory structure
mkdir -p /tmp/busybox/bin

# Copy the core binary over and apply execution permissions
cp /tmp/busybox-x86_64-linux-gnu /tmp/busybox/bin/busybox
chmod +x /tmp/busybox/bin/busybox

# 3. Create an automatic path dispatcher script template
# This version correctly passes the applet name to the core busybox executable
cat << 'INNER_EOF' > /tmp/dispatcher_template
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
APPNAME="$(basename "$0")"
exec "$DIR/bin/busybox" "$APPNAME" "$@"
INNER_EOF

# 4. Populate the root busybox folder with dynamic links to the dispatcher
cd /tmp/busybox
for applet in $(./bin/busybox --list); do
    cp /tmp/dispatcher_template "./$applet"
    chmod +x "./$applet"
done

# 5. Clean up the temporary template file
rm /tmp/dispatcher_template

# 6. Save file permissions and copy the compressed archive to the host as 'busybox.tar.gz'
cd /tmp
tar -czf /out/busybox.tar.gz busybox
chown -R $(id -u):$(id -g) /out/busybox.tar.gz
EOF

