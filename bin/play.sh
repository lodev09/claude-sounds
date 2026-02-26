#!/bin/bash
DEST="$HOME/.claude/sounds"
EVENT="$1"

[ -z "$EVENT" ] && exit 0
[ ! -f "$DEST/.enabled" ] && exit 0
[ ! -f "$DEST/.source" ] && exit 0

SOURCE="$(cat "$DEST/.source")"
ENABLED="$(cat "$DEST/.enabled")"

files=$(python3 -c "
import json, os
source = '$SOURCE'
event = '$EVENT'
enabled = '''$ENABLED'''.strip().splitlines()
for char in enabled:
    path = os.path.join(source, 'sounds', char, 'source.json')
    if not os.path.isfile(path):
        continue
    with open(path) as f:
        data = json.load(f)
    for name in data.get(event, []):
        print(os.path.join(source, 'sounds', char, name))
")

[ -z "$files" ] && exit 0

existing=()
while IFS= read -r f; do [[ -f "$f" ]] && existing+=("$f"); done <<< "$files"
[[ ${#existing[@]} -eq 0 ]] && exit 0

VOLUME=$([ -f "$DEST/.volume" ] && cat "$DEST/.volume" || echo "0.25")
afplay -v "$VOLUME" "${existing[RANDOM % ${#existing[@]}]}" &
