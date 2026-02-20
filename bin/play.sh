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
    path = os.path.join(source, 'sounds', char, 'sounds.json')
    if not os.path.isfile(path):
        continue
    with open(path) as f:
        data = json.load(f)
    for name in data.get(event, []):
        print(os.path.join(source, 'sounds', char, name))
")

[ -z "$files" ] && exit 0

mapfile -t arr <<< "$files"
existing=()
for f in "${arr[@]}"; do [[ -f "$f" ]] && existing+=("$f"); done
[[ ${#existing[@]} -eq 0 ]] && exit 0
afplay -v 0.25 "${existing[RANDOM % ${#existing[@]}]}" &
