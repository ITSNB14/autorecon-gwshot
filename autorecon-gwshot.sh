#!/usr/bin/env bash
set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo "Usage: $0 <target-ip>"
    exit 1
fi

target="$1"
BASE="$HOME/Tools/pentest/results/$target"
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt"
URL_FILE="$BASE/screenshot-urls.txt"
GOBUSTER_RESULTS="$BASE/gobuster-results.txt"

echo -e "${RED}[*] Checking prerequisites...${NC}"
for bin in autorecon gobuster gwshot; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "Missing required binary: $bin"
        exit 1
    fi
done
if [ ! -f "$WORDLIST" ]; then
    echo "Wordlist not found: $WORDLIST"
    exit 1
fi
echo -e "${GREEN}[+] Prerequisites OK${NC}"

mkdir -p "$BASE"

echo -e "${RED}[*] Running AutoRecon against $target...${NC}"
autorecon --max-scans 5 "$target" -o "$BASE"
echo -e "${GREEN}[+] AutoRecon finished${NC}"

> "$URL_FILE"
> "$GOBUSTER_RESULTS"

# Base URLs to probe. Uncomment to add alt ports.
base_urls=(
    "http://$target:80"
    "https://$target:443"
    # "http://$target:8080"
    # "https://$target:8443"
)

for base_url in "${base_urls[@]}"; do
    # Strip any trailing slash so URL construction is always base + /path
    base_url="${base_url%/}"

    echo -e "${RED}[*] Checking connectivity: $base_url${NC}"
    code=$(curl -kL --connect-timeout 5 --max-time 15 "$base_url/" \
        -o /dev/null -w "%{http_code}")

    if [ "$code" != "200" ]; then
        echo "[-] Skipping $base_url (HTTP $code)"
        continue
    fi
    echo -e "${GREEN}[+] $base_url is up (HTTP 200)${NC}"

    safe_name=$(echo "$base_url" | sed 's#://#_#; s#:#_#g')
    gobuster_output="$BASE/gobuster_${safe_name}.txt"

    echo -e "${RED}[*] Running gobuster against $base_url...${NC}"
    gobuster dir -u "$base_url" -w "$WORDLIST" -o "$gobuster_output" \
        -s 200,204,301,302,307,401,403 \
        --status-codes-blacklist "" \
        -k \
        -t 2 -q

    # Base URL always goes into screenshot list, even if zero paths found
    echo "$base_url" >> "$URL_FILE"

    if [ ! -s "$gobuster_output" ]; then
        echo -e "${YELLOW}[-] No gobuster output for $base_url${NC}"
        continue
    fi
    echo -e "${GREEN}[+] Gobuster finished: $gobuster_output${NC}"

    found=$(grep -cE '^/.*Status:' "$gobuster_output" 2>/dev/null || echo 0)
    echo -e "${GREEN}[+] Discovered $found paths for $base_url${NC}"

    {
        echo "========================================"
        echo "Base URL: $base_url"
        echo "========================================"
    } >> "$GOBUSTER_RESULTS"

    echo -e "${RED}[*] Parsing gobuster output for $base_url...${NC}"
    while IFS= read -r line; do
        # Skip blank lines
        [ -z "$line" ] && continue

        # Gobuster 3.6 line format: /path (Status: 200) [Size: 113]
        # Redirect lines look like: /dept (Status: 301) [Size: 319] [--> http://.../dept/]
        # awk '{print $1}' still yields just /path in both cases
        path=$(echo "$line" | awk '{print $1}')
        status=$(echo "$line" | grep -oE 'Status: [0-9]+' | awk '{print $2}')

        if [ -z "$path" ]; then
            echo "[debug] Could not extract path from line: $line"
            continue
        fi

        # Ensure path starts with exactly one leading slash
        case "$path" in
            /*) : ;;          # already starts with /
            *)  path="/$path" ;;
        esac

        echo "[debug] line=\"$line\" -> path=\"$path\" status=\"$status\""

        full_url="${base_url}${path}"
        echo "$full_url" >> "$URL_FILE"
        echo "$path (Status: $status)" >> "$GOBUSTER_RESULTS"
    done < "$gobuster_output"

    echo "" >> "$GOBUSTER_RESULTS"
done

if [ -f "$URL_FILE" ]; then
    sort -u "$URL_FILE" -o "$URL_FILE"
fi

echo -e "${RED}[*] Gobuster results by base URL: $GOBUSTER_RESULTS${NC}"
cat "$GOBUSTER_RESULTS"

echo -e "${RED}[*] First 20 lines of $URL_FILE (verify before screenshotting):${NC}"
head -n 20 "$URL_FILE"

if [ ! -s "$URL_FILE" ]; then
    echo "[-] No URLs to screenshot. Exiting."
    exit 1
fi

mkdir -p "$BASE/screenshots"

echo -e "${RED}[*] Running gowitness via gwshot...${NC}"
# --screenshot-fullpage is optional (slow); add if you need full-page captures
gwshot scan file --file "$URL_FILE" --delay 5 \
    --screenshot-path "$BASE/screenshots" -D

echo -e "${GREEN}[+] Done. Screenshots in: $BASE/screenshots${NC}"
echo -e "${GREEN}[+] Full URL list: $URL_FILE${NC}"
echo -e "${GREEN}[+] Gobuster results by base URL: $GOBUSTER_RESULTS${NC}"
