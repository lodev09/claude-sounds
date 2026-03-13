#!/bin/bash
#
# Tests for the cross-platform filename pre-commit hook.
#
# Creates a temporary git repo, installs the hook, and verifies it correctly
# rejects forbidden characters and allows valid ones.
#
# Characters that cannot exist in Windows filenames (? * : < > | ") are tested
# by creating a wrapper that fakes the git-diff output, so the tests run on
# all platforms.
#
# Usage: bash tests/test-pre-commit-hook.sh

set -euo pipefail

HOOK_PATH="$(cd "$(dirname "$0")/.." && pwd)/hooks/pre-commit"
PASS=0
FAIL=0
TESTS=0

cleanup() {
  if [ -n "${TMPDIR_TEST:-}" ] && [ -d "$TMPDIR_TEST" ]; then
    rm -rf "$TMPDIR_TEST"
  fi
}
trap cleanup EXIT

# ---- Strategy 1: Real git commits (for characters the OS allows) ----

setup_repo() {
  cleanup
  TMPDIR_TEST="$(mktemp -d)"
  cd "$TMPDIR_TEST"
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test"
  touch .gitkeep
  git add .gitkeep
  git commit -q -m "init"
  cp "$HOOK_PATH" .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
}

assert_real_commit_succeeds() {
  local desc="$1"
  local filename="$2"
  TESTS=$((TESTS + 1))

  setup_repo
  mkdir -p "$(dirname "$filename")" 2>/dev/null || true
  touch "$filename"
  git add -- "$filename"
  if git commit -q -m "test" 2>/dev/null; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (expected success, got rejection)"
  fi
}

assert_real_commit_fails() {
  local desc="$1"
  local filename="$2"
  TESTS=$((TESTS + 1))

  setup_repo
  touch "$filename"
  git add -- "$filename"
  if git commit -q -m "test" 2>/dev/null; then
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (expected rejection, got success)"
  else
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  fi
}

# ---- Strategy 2: Simulated git-diff (for forbidden OS characters) ----
# Runs the hook logic directly with a fake git command that outputs
# the test filename as if it were staged.

assert_hook_rejects() {
  local desc="$1"
  local filename="$2"
  TESTS=$((TESTS + 1))

  cleanup
  TMPDIR_TEST="$(mktemp -d)"
  cd "$TMPDIR_TEST"

  # Create a script that pretends to be git and outputs our test filename
  # when called with "diff --cached ..."
  cat > fake-git <<'FAKEGIT'
#!/bin/bash
if [[ "$1" == "diff" ]]; then
  printf '%s\0' "$FAKE_FILENAME"
else
  command git "$@"
fi
FAKEGIT
  chmod +x fake-git

  # Run the hook with our fake git on PATH
  export FAKE_FILENAME="$filename"
  export PATH="$TMPDIR_TEST:$PATH"
  # Rename fake-git to git
  cp fake-git git
  chmod +x git

  if bash "$HOOK_PATH" >/dev/null 2>&1; then
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (expected rejection, got success)"
  else
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  fi
}

assert_hook_allows() {
  local desc="$1"
  local filename="$2"
  TESTS=$((TESTS + 1))

  cleanup
  TMPDIR_TEST="$(mktemp -d)"
  cd "$TMPDIR_TEST"

  cat > git <<'FAKEGIT'
#!/bin/bash
if [[ "$1" == "diff" ]]; then
  printf '%s\0' "$FAKE_FILENAME"
else
  command git "$@"
fi
FAKEGIT
  chmod +x git

  export FAKE_FILENAME="$filename"
  export PATH="$TMPDIR_TEST:$PATH"

  if bash "$HOOK_PATH" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (expected success, got rejection)"
  fi
}

echo "Running pre-commit hook tests..."
echo ""

# --- Forbidden character tests (should reject) ---
# Use simulated git-diff so these work on all platforms, including Windows
# where most of these characters are illegal in filenames.
echo "Forbidden characters (should reject):"

assert_hook_rejects "question mark" "hello?.wav"
assert_hook_rejects "asterisk" "hello*.wav"
assert_hook_rejects "colon" "hello:.wav"
assert_hook_rejects "less than" "hello<.wav"
assert_hook_rejects "greater than" "hello>.wav"
assert_hook_rejects "pipe" "hello|.wav"
assert_hook_rejects "comma" "hello,.wav"
assert_hook_rejects "double quote" 'hello".wav'
assert_hook_rejects "backslash" 'hello\.wav'

echo ""

# --- Allowed character tests (should succeed) ---
echo "Allowed characters (should succeed):"

assert_hook_allows "alphanumeric" "hello123.wav"
assert_hook_allows "spaces" "hello world.wav"
assert_hook_allows "hyphens" "hello-world.wav"
assert_hook_allows "dots" "hello.world.wav"
assert_hook_allows "underscores" "hello_world.wav"
assert_hook_allows "single quotes" "it's a file.wav"
assert_hook_allows "parentheses" "track (1).wav"
assert_hook_allows "path separators" "subdir/file.wav"

echo ""

# --- Edge cases ---
echo "Edge cases:"

# Forbidden chars in directory components should NOT trigger rejection
# because the hook checks basename only
assert_hook_allows "forbidden char in directory only" "sub,dir/clean-file.wav"

# Multiple forbidden chars in basename
assert_hook_rejects "multiple forbidden chars" "what?!<>.wav"

echo ""

# --- Integration test with real git (using characters safe on all platforms) ---
echo "Integration tests (real git commits):"

assert_real_commit_succeeds "real commit with clean filename" "good-file.wav"
assert_real_commit_fails "real commit with comma" "bad,file.wav"

echo ""

# --- Summary ---
echo "Results: $PASS/$TESTS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
