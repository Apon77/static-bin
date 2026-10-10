# Static Bin PM (`bin`)

Lightweight dynamic package manager for static binaries. Works on Linux and BusyBox/Alpine.

## Setup
```bash
chmod +x bin && mv bin ~/bin/
export PATH="HOME/bin:PATH"
```

## Usage

### Install
```bash
bin i <pkg1> <pkg2> ...
# Example: bin i curl vim ngrok
```

### Remove
```bash
bin r <pkg1> <pkg2> ...
# Example: bin r vim curl
```
