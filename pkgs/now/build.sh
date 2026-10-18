sudo apt-get update && sudo apt-get install -y build-essential musl-tools musl-dev upx-ucl

# modifed from this
# https://raw.githubusercontent.com/BaseMax/file-downloader-c/refs/heads/main/file-downloader.c

# Compile static & optimize for size (-Os)
musl-gcc -static -Os -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,-z,norelro now.c -o now

#or in android
aarch64-linux-musl-gcc -static -Os -fdata-sections -ffunction-sections -Wl,--gc-sections -Wl,-z,norelro -o now now.c

# Strip file to absolute minimal byte size
strip --strip-all now

upx --ultra-brute now
