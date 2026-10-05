# Pentest Screenshot Automation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)]()

An automated reconnaissance pipeline that chains **AutoRecon**, **Gobuster**, and **Gowitness** to streamline web enumeration and visual verification during penetration tests.

## The Problem

Standard recon tools don't talk to each other. AutoRecon's Markdown reports aren't structured for easy URL extraction, Gobuster's default status-code blacklist silently breaks naive `-s` filtering, and manually screenshotting every discovered endpoint across a target list is slow and error-prone. This script automates the full chain — scan, enumerate, extract, and screenshot — and handles the specific failure modes each tool hits in practice (expired certs, driver timeouts, malformed URLs).

## Features

- **Automated Workflow:** Chains three tools (AutoRecon → Gobuster → Gowitness) into a single execution flow.
- **Smart URL Extraction:** Automatically identifies live HTTP/HTTPS services and extracts discovered paths into clean, screenshot-ready URLs.
- **Visual Verification:** Uses Gowitness (with the `gorod` driver, which avoids the `chromedp` timeout issues common on low-resource VMs) to capture every discovered endpoint.
- **Clean Reporting:** Generates a structured `gobuster-results.txt` grouped by base URL, plus a deduplicated `screenshot-urls.txt`.
- **Resilient by Design:** Handles expired/self-signed TLS certs, double-slash URL bugs, and Gobuster 3.6's status-code blacklist conflict out of the box.
- **Parrot OS / Kali Optimized:** Tested against the real quirks of these environments, not a generic Linux assumption.

## Prerequisites

These commands reflect what actually works on Parrot OS and Kali — not the generic `apt install` path, which does not work for AutoRecon or Gowitness.

**AutoRecon** (not available via apt — install with pipx):
```bash
sudo apt install pipx -y
pipx ensurepath
pipx install autorecon
```

**Gobuster 3.6+:**
```bash
sudo apt install gobuster -y
gobuster version
```
If your repo version is older than 3.6, grab a current binary from the [official releases page](https://github.com/OJ/gobuster/releases).

**Gowitness** (build from source — pre-built binaries are frequently the wrong architecture and will fail with `exec format error`):
```bash
go install github.com/sensepost/gowitness@latest
file ~/go/bin/gowitness   # confirm it matches your system architecture
```

**Chromium** (required for headless screenshotting):
```bash
sudo apt install chromium -y
```

**Wordlist** (ships with SecLists on Parrot OS):
```bash
ls /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt
```

Full step-by-step setup, including the required `gwshot` wrapper, is in [`docs/setup.md`](docs/setup.md).

## Quick Start

```bash
git clone https://github.com/ITSNB14/ITSNB14.git
cd ITSNB14
chmod +x autorecon-gwshot.sh
# Set up ~/bin/gwshot first — see docs/setup.md
./autorecon-gwshot.sh 192.168.1.10
```

## Usage Example

```bash
./autorecon-gwshot.sh 192.168.1.10
```

**Sample terminal output:**
```text
[*] Checking prerequisites...
[+] Prerequisites OK
[*] Running AutoRecon against 192.168.1.10...
[+] AutoRecon finished
[*] Checking connectivity: http://192.168.1.10:80
[+] http://192.168.1.10:80 is up (HTTP 200)
[*] Running gobuster against http://192.168.1.10:80...
[+] Gobuster finished: gobuster_http_192.168.1.10_80.txt
[+] Discovered 7 paths for http://192.168.1.10:80
[*] Checking connectivity: https://192.168.1.10:443
[+] https://192.168.1.10:443 is up (HTTP 200)
[*] Running gobuster against https://192.168.1.10:443...
[+] Discovered 4 paths for https://192.168.1.10:443
[*] First 20 lines of screenshot-urls.txt (verify before screenshotting):
http://192.168.1.10:80
http://192.168.1.10:80/admin
http://192.168.1.10:80/login
http://192.168.1.10:80/robots.txt
https://192.168.1.10:443
https://192.168.1.10:443/admin
[*] Running gowitness via gwshot...
[+] Done. Screenshots in: results/192.168.1.10/screenshots
```

**Sample `gobuster-results.txt`:**
```text
========================================
Base URL: http://192.168.1.10:80
========================================
/robots.txt (Status: 200)
/admin (Status: 301)
/login (Status: 200)

========================================
Base URL: https://192.168.1.10:443
========================================
/admin (Status: 403)
```

**Output structure:**
```
results/
└── 192.168.1.10/
    ├── screenshot-urls.txt      # Clean, deduplicated list of URLs for Gowitness
    ├── gobuster-results.txt     # Structured directory findings, grouped by base URL
    ├── screenshots/             # Captured screenshots of every discovered endpoint
    └── ...                      # Full AutoRecon output
```

## Disclaimer

This tool is intended for authorized security testing only. Use it only on systems you own or have explicit written permission to test. The author is not responsible for any misuse or damage caused by this software.

## Contributing

Feel free to open issues or submit pull requests for improvements.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
