#!/usr/bin/env bash
#
# example-usage.sh
#
# Demonstrates common ways to run autorecon-gwshot.sh.
# This file is illustrative only — it does not run anything by itself
# unless you uncomment a block below.

set -u

SCRIPT="$HOME/autorecon-gwshot.sh"

echo "== Pentest Screenshot Automation: example invocations =="
echo

echo "1) Single target:"
echo "   $SCRIPT 192.168.0.150"
echo

echo "2) Multiple targets in sequence (e.g. a small internal range):"
echo '   for ip in 192.168.0.150 192.168.0.151 192.168.0.152; do'
echo '       '"$SCRIPT"' "$ip"'
echo '   done'
echo

echo "3) Re-running gobuster standalone against a single base URL"
echo "   (useful for quick checks without the full 8-minute AutoRecon run):"
echo '   gobuster dir -u http://192.168.0.150 \'
echo '       -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt \'
echo '       -s 200,204,301,302,307,401,403 \'
echo '       --status-codes-blacklist "" \'
echo '       -k -t 2 -q -o /tmp/gb-test.txt && cat /tmp/gb-test.txt'
echo

echo "4) Re-running gowitness standalone against an existing URL list"
echo "   (useful after manually editing screenshot-urls.txt):"
echo '   gwshot scan file --file ~/Tools/pentest/results/192.168.0.150/screenshot-urls.txt \'
echo '       --delay 5 \'
echo '       --screenshot-path ~/Tools/pentest/results/192.168.0.150/screenshots \'
echo '       -D'
echo

echo "To actually run the tool against a real target, call it directly:"
echo "   $SCRIPT <target-ip>"
