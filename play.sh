#!/bin/bash
SOUNDS_DIR="$(dirname "$0")"
files=("$SOUNDS_DIR"/${1}/*.{wav,mp3})
existing=()
for f in "${files[@]}"; do [[ -f "$f" ]] && existing+=("$f"); done
[[ ${#existing[@]} -eq 0 ]] && exit 0
afplay -v 0.25 "${existing[RANDOM % ${#existing[@]}]}" &
