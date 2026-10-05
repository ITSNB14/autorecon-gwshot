# Changelog

All notable changes to this project are documented in this file.

## [1.0.0] - 2026-10-05

### Added
- Initial release of `autorecon-gwshot.sh`: chains AutoRecon → Gobuster →
  gowitness for automated web screenshotting during pentests.
- `gwshot` wrapper script to force the `gorod` driver (avoids `chromedp`
  timeout issues) and ensure the correct Chromium path is always passed.
- `gobuster-results.txt` output: a human-readable breakdown of discovered
  paths grouped by base URL.
- Pre-flight checks for required binaries (`autorecon`, `gobuster`,
  `gwshot`) and wordlist presence before starting a run.

### Fixed
- Resolved Gobuster 3.6 argument conflict where `-s` (status-codes) clashed
  with the default `status-codes-blacklist` of `404`. Fixed by explicitly
  passing `--status-codes-blacklist ""` alongside `-s`.
- Resolved HTTPS targets with expired or self-signed certificates causing
  Gobuster to fail with a TLS verification error. Fixed by adding `-k` to
  skip certificate verification (standard practice for pentest targets).
- Fixed base URLs being dropped from `screenshot-urls.txt` when Gobuster
  found zero valid paths; base URLs are now always written before the
  empty-output check.
- Fixed path parsing so Gobuster's redirect-arrow output format
  (`/path (Status: 301) [Size: 319] [--> http://...]`) still extracts a
  clean path instead of swallowing the redirect target.
- Fixed double-slash URL construction (e.g. `http://target:80//admin`) by
  stripping trailing slashes from base URLs before concatenation.
