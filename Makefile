RELEASE_TAG = v1.0.0
CHECKSUM_FILE = checksums.txt
BUILD_DATE = 2026-10-04 00:00:00Z

explicit_pkgs = $(shell grep -E '^[a-zA-Z0-9_-]+:' Makefile | cut -d: -f1 | sort -u | grep -Ev 'all|clean|help')
pkgs = $(explicit_pkgs) $(ryanwoodsmall_bin)

ryanwoodsmall_url = https://github.com/ryanwoodsmall/static-binaries/raw/refs/heads/master/x86_64
ryanwoodsmall_bin = \
		    ag \
		    bash \
		    busybox \
		    ccache \
		    coreutils \
		    curl \
		    dash \
		    dropbearmulti \
		    jq \
		    less \
		    links \
		    make \
		    mk \
		    nc \
		    pv \
		    rc \
		    rsync \
		    screen \
		    socat \
		    sslh \
		    stunnel \
		    tini \
		    tmux \
		    toybox \
		    unrar \
		    xml \
		    xz

define pack
	tar --sort=name \
	    --mtime='$(BUILD_DATE)' \
	    --owner=0 --group=0 --numeric-owner \
	    --use-compress-program="pigz -n -k -6" \
	    -cf "$@.tar.gz" "$(or $(file),$@)"
	shasum -a 256 "$@.tar.gz" >> $(CHECKSUM_FILE)
	rm -rf "$(or $(file),$@)"
	@echo "---------------------------$@ completed--------------------"
endef

.PHONY: help clean all $(pkgs)

all: init-checksums $(pkgs)
init-checksums:
	> $(CHECKSUM_FILE)
ryan: $(ryanwoodsmall_bin)

aria2:
	curl -fsSL https://github.com/P3TERX/Aria2-Pro-Core/releases/download/1.36.0_2021.08.22/aria2-1.36.0-static-linux-amd64.tar.gz | tar -xz && mkdir -p aria2/bin && mv aria2c aria2/bin/
	$(pack)

neovim:
	curl -fsSL https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz | tar -xz && mv nvim* neovim
	$(pack)

ngrok:
	curl -fsSL https://bin.ngrok.com/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz
	$(pack)

tailscale:
	curl -fsSL https://pkgs.tailscale.com/stable/tailscale_1.102.4_amd64.tgz | tar -xz && mv tailscale_* tailscale
	$(pack)

vim:
	curl -fsSL https://github.com/heywoodlh/vim-builds/releases/download/9.2/vim-x86_64 -o vim && chmod +x vim
	$(pack)

$(ryanwoodsmall_bin): %:
	curl -fsSLO $(ryanwoodsmall_url)/$@ && chmod +x $@
	$(pack)

zverify: 
	@if [ -f $(CHECKSUM_FILE) ]; then \
		shasum -a 256 -c $(CHECKSUM_FILE); \
	else \
		echo "No $(CHECKSUM_FILE) found."; \
	fi
	@echo "---------------------------$@ completed--------------------"

clean::
	rm -rf *.tar.gz
	rm -rf $(pkgs)
