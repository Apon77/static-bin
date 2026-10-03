# Static Bin PM (`bin`)

Lightweight dynamic package manager for static binaries. Works on Linux and BusyBox/Alpine systems.

## Setup

```
curl -fsSL --create-dirs https://github.com/Apon77/static-bin/raw/refs/heads/main/bin -o ~/bin/bin
chmod +x ~/bin/bin
export PATH="$HOME/bin:$PATH"
```

## Usage

### Install Packages

```
bin i <pkg1> <pkg2> ...
# Example: bin i curl vim ngrok
```

### Remove Packages

```
bin r <pkg1> <pkg2> ...
# Example: bin r vim curl
```

### Search Packages

```
bin s <pkg1> <pkg2> ...
# Example: bin s vim
```

## Build & Release Management

This repository includes a `Makefile` to automate fetching, building, packaging binaries into reproducible `.tar.gz` archives, and generating SHA-256 checksums.

### Prerequisites

Make sure your system has the following tools installed for build tasks:

* `curl`

* `tar`

* `pigz`

* `shasum`

* `make`

### Clone Repository

```
git clone https://github.com/Apon77/static-bin -b main ~/static-bin
cd ~/static-bin
```

### Build Targets

* **Build All Packages**: Cleanly initializes `checksums.txt` and builds all supported targets.

  ```
  make all
  ```

* **Build Specific Package**:

  ```
  make neovim
  make ngrok
  make vim
  ```

* **Build Ryan Woodsmall Binaries**: Builds only the set of binaries sourced from upstream static builds.

  ```
  make ryan
  ```

* **Verify Checksums**: Verifies all generated package archives against `checksums.txt`.

  ```
  make zverify
  ```

* **Clean Build Artifacts**: Removes all built archives (`.tar.gz`) and uncompressed binaries.

  ```
  make clean
  ```

## Available Packages

### Custom / Explicit Targets

* `aria2`

* `neovim`

* `ngrok`

* `tailscale`

* `vim`

### Upstream Binaries (`ryanwoodsmall`)

* `ag`, `bash`, `busybox`, `ccache`, `coreutils`, `curl`, `dash`, `dropbearmulti`, `jq`, `less`, `links`, `make`, `mk`, `nc`, `pv`, `rc`, `rsync`, `screen`, `socat`, `sslh`, `stunnel`, `tini`, `tmux`, `toybox`, `unrar`, `xml`, `xz`
