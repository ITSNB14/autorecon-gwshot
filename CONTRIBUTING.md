# Contributing

Thanks for considering a contribution. This is a small, focused tool — here's how to help without a lot of ceremony.

## Reporting Bugs

Before filing an issue, confirm it's reproducible and not already covered in the [README troubleshooting notes](README.md) or [CHANGELOG.md](CHANGELOG.md) (a few known failure modes — expired certs, the Gobuster 3.6 status-code blacklist conflict, wrong-architecture Gowitness binaries — are already documented fixes, not bugs).

When you do file one, include:

- Your OS and version (`cat /etc/os-release`)
- Versions of the relevant tool(s): `autorecon --version`, `gobuster version`, `~/go/bin/gowitness version`
- The exact command you ran
- The full terminal output, including any `[debug]` lines the script printed
- What you expected to happen vs. what actually happened

Redact real target IPs/hostnames if the report is going somewhere public. "192.168.x.x" or an obviously fake IP is fine.

## Suggesting Features

Open an issue describing the problem you're hitting, not just the feature you want — e.g. "I need to screenshot ports other than 80/443" is more useful than "add more ports." This project intentionally stays small and chain-oriented (AutoRecon → Gobuster → Gowitness); if a suggestion is really a different tool bolted on, it's probably better as its own fork or a flag rather than baked into the core script.

## Submitting Pull Requests

1. Fork the repo and branch off `main`: `git checkout -b feature/short-description`
2. Keep PRs focused — one fix or feature per PR. Don't bundle unrelated cleanup.
3. Update `CHANGELOG.md` under an `[Unreleased]` section at the top.
4. If you changed behavior (new flag, new output file, changed defaults), update `README.md` and/or `docs/setup.md` to match. A PR that changes behavior without updating docs will get asked to do both.
5. Describe what you tested and on what OS/VM in the PR description (see Testing Requirements below).
6. Open the PR against `main`.

## Code Style (Bash)

Nothing fancy, just consistency with what's already here:

- `set -u` at the top of every script. **Do not add `set -e`** — the whole point of this tool is that one failed Gobuster run or one unreachable port shouldn't kill the rest of the chain.
- Quote your variables: `"$target"`, not `$target`. This script deals with user-supplied IPs and file paths; unquoted expansion is how double-slash-URL and word-splitting bugs sneak back in.
- When a line continues, the `\` must be the **last character on the line** — no trailing whitespace after it, or the continuation silently breaks.
- Prefer explicit `if [ ... ]; then` over `[[ ]]`-only idioms unless you specifically need `[[`'s pattern matching (we do use it in a couple of `case` statements for path normalization — that's fine).
- Don't invent flags for `gobuster`/`gowitness` that aren't confirmed to exist in the version this project targets (Gobuster 3.6+, Gowitness built from current `main`). Check `gobuster dir -h` / `gowitness scan file -h` before adding a new flag, and note the confirmed version in your PR.
- Color output (`RED`/`GREEN`/`YELLOW` via `\033[...]`) is used for action/success/warning lines — keep new output consistent with that pattern rather than introducing a new scheme.
- Run `shellcheck` on anything you touch if you have it installed. Not currently enforced in CI, but it catches real bugs.

## Testing Requirements

**This tool runs active enumeration (Gobuster) and automated browser screenshotting (Gowitness) against live targets. Test only in a lab environment you control or are explicitly authorized to scan. Never test against production systems, systems you don't own, or systems without written authorization.**

Practical minimum before opening a PR:

- Test on **Kali Linux or Parrot OS** (the two environments this project targets). If you only have access to one, say so in the PR and someone can verify on the other.
- Test against a local/lab VM with at least one HTTP and one HTTPS service (a deliberately vulnerable VM like Metasploitable, DVWA, or a throwaway Docker container works well — self-signed/expired certs are a good edge case to include since that's a known failure mode).
- Confirm the full chain still runs end-to-end: AutoRecon finishes, `gobuster-results.txt` and `screenshot-urls.txt` are populated correctly, and actual screenshot files land in `screenshots/`.
- If your change touches URL construction or path parsing, specifically test a target with at least one redirect (`Status: 301`) and one path containing a trailing slash — those are the two bug classes that have bitten this project before.

No formal test suite exists yet — if you want to add one (e.g. a script that feeds canned Gobuster output through the parsing logic and checks the resulting URLs), that's a very welcome contribution on its own.
