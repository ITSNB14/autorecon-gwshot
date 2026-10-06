# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-05

Initial release.

### Added
- Core pipeline chaining **AutoRecon → Gobuster → Gowitness** for automated
  web screenshotting during penetration tests.
- `gwshot` wrapper script that forces Gowitness's `gorod` driver (the default
  `chromedp` driver times out on low-resource VMs) and pins the correct
  Chromium path and binary on every invocation.
- Automated base-URL construction and connectivity checks (`curl -kL`) for
  common HTTP/HTTPS ports before launching Gobuster.
- `gobuster-results.txt`: a structured, human-readable breakdown of
  discovered paths grouped by base URL.
- `screenshot-urls.txt`: a clean, deduplicated URL list consumed directly by
  Gowitness.
- Pre-flight dependency checks for `autorecon`, `gobuster`, `gwshot`, and the
  target wordlist before a run starts.
- Debug output (`-D` passthrough to Gowitness, explicit path-parsing echoes)
  for troubleshooting failed runs.
- Documentation: `docs/setup.md` installation guide, `example-usage.sh`
  reference script, and `CONTRIBUTING.md`.
- Tested and optimized for **Kali Linux** and **Parrot OS**.

### Fixed
- **Gobuster 3.6 status-code conflict:** `-s` (status-codes) clashed with
  Gobuster 3.6's default `status-codes-blacklist` of `404`, causing the
  tool to exit with an argument-parsing error before producing any output.
  Resolved by explicitly passing `--status-codes-blacklist ""` alongside
  `-s`.
- **Expired/self-signed certificate failures:** Gobuster aborted against
  HTTPS targets with expired or self-signed certificates
  (`x509: certificate has expired or is not yet valid`). Resolved by adding
  `-k` to skip TLS verification, consistent with standard pentest-lab
  practice.
- **Double-slash URL construction:** Concatenating a base URL ending in `/`
  with a discovered path starting in `/` produced malformed URLs (e.g.
  `http://target:80//admin`), which Gowitness and some web servers handled
  inconsistently. Resolved by stripping trailing slashes from base URLs
  before concatenation.
- **Dropped base URLs on empty Gobuster results:** When Gobuster found zero
  valid paths for a target, the base URL itself was never written to
  `screenshot-urls.txt`, so root pages were silently skipped. Resolved by
  writing the base URL before the empty-output check runs.
- **Redirect-arrow parsing:** Gobuster's redirect output format
  (`/path (Status: 301) [Size: 319] [--> http://...]`) was not reliably
  reduced to a clean path in earlier iterations. Resolved by anchoring
  extraction to the first field only.
- **Wrong-architecture Gowitness binary:** A previously installed Gowitness
  binary at a different path caused `exec format error` on Parrot OS.
  Documented the fix (build from source, verify with `command -v gowitness`
  and `hash -r`) in `docs/setup.md`.

[1.0.0]: https://github.com/ITSNB14/autorecon-gwshot/releases/tag/v1.0.0
