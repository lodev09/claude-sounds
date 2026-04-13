#!/bin/bash

DIM='\033[2m'
BOLD='\033[1m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

info() { printf "${GREEN}✓${RESET} %s\n" "$1"; }
dim() { printf "${DIM}%s${RESET}\n" "$1"; }
err() { printf "${RED}✗${RESET} %s\n" "$1"; }

spinner_pid=""

cleanup() {
  if [ -n "$spinner_pid" ]; then
    kill $spinner_pid 2>/dev/null
    wait $spinner_pid 2>/dev/null
  fi
  printf "\n"
  exit 1
}
trap cleanup INT TERM

spin() {
  local msg="$1"
  shift
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local error_file
  error_file=$(mktemp)

  (
    while true; do
      for frame in "${frames[@]}"; do
        printf "\r${DIM}%s${RESET} %s" "$frame" "$msg"
        sleep 0.08
      done
    done
  ) &
  spinner_pid=$!

  local exit_code=0
  "$@" >"$error_file" 2>&1 || exit_code=$?

  kill $spinner_pid 2>/dev/null || true
  wait $spinner_pid 2>/dev/null || true
  spinner_pid=""

  if [ $exit_code -eq 0 ]; then
    printf "\r${GREEN}✓${RESET} ${BOLD}%s${RESET}\n" "$msg"
  else
    printf "\r${RED}✗${RESET} ${BOLD}%s${RESET}\n" "$msg"
    [ -s "$error_file" ] && printf "  ${RED}→${RESET} %s\n" "$(cat "$error_file")"
    rm -f "$error_file"
    exit 1
  fi

  rm -f "$error_file"
}
