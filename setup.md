# Setup Guide (Parrot OS)

This guide covers installing the prerequisites and configuring the `gwshot`
wrapper used by `autorecon-gwshot.sh`.

## 1. Prerequisites

### AutoRecon

```bash
sudo pipx install autorecon
# or, if pipx is not installed:
sudo apt install pipx -y
pipx ensurepath
pipx install autorecon
```

Verify:

```bash
autorecon --version
```

### Gobuster

Parrot OS ships Gobuster in its repos:

```bash
sudo apt update
sudo apt install gobuster -y
gobuster version
```

This project is built against **Gobuster 3.6**. If your repo version is
older, install a newer binary from the
[OJ/gobuster releases page](https://github.com/OJ/gobuster/releases) instead.

### Chromium

```bash
sudo apt install chromium -y
command -v chromium
```

Confirm headless screenshotting works standalone before relying on gowitness:

```bash
chromium --headless --screenshot=/tmp/test.png https://example.com
```

### Gowitness

Parrot's packaged `gowitness` (if any) may be built for the wrong
architecture. Build from source to avoid `exec format error`:

```bash
go install github.com/sensepost/gowitness@latest
```

The resulting binary will be at `~/go/bin/gowitness`. Confirm:

```bash
file ~/go/bin/gowitness
~/go/bin/gowitness version
```

### Wordlist

This project uses SecLists' dirbuster wordlist, available by default on
Parrot OS:

```bash
ls /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt
```

If missing:

```bash
sudo apt install seclists -y
```

## 2. The `gwshot` wrapper

Gowitness's default `chromedp` driver times out in low-resource VMs. This
project uses the `gorod` driver instead, wrapped in a small script so every
invocation gets the right flags automatically.

Create `~/bin/gwshot`:

```bash
mkdir -p ~/bin
cat > ~/bin/gwshot << 'EOF'
#!/usr/bin/env bash
exec /home/nb14/go/bin/gowitness \
  "$@" \
  --chrome-path "$(command -v chromium)" \
  --driver gorod \
  --write-db
EOF
chmod +x ~/bin/gwshot
```

Make sure `~/bin` is in your `PATH`:

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify the wrapper resolves to the correct binary:

```bash
hash -r
command -v gwshot
command -v gowitness
```

`command -v gowitness` should return `/home/nb14/go/bin/gowitness`, **not**
`/usr/local/bin/gowitness` (a common source of `exec format error` if a
mismatched-architecture binary exists at that path).

## 3. Running the tool

```bash
chmod +x ~/autorecon-gwshot.sh
~/autorecon-gwshot.sh <target-ip>
```

See `example-usage.sh` for more invocation examples.
