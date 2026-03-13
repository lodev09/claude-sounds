---
verdict: APPROVAL
card_id: n7g12q
review_number: 2
commit: 233feba
date: 2026-03-13
has_backlog_items: true
---

All blockers from review 1 are resolved.

**B1 (source.json references non-existent files):** The four missing `.wav` files (`yes milord.wav`, `more work.wav`, `yes.wav`, `what you want.wav`) are now present on disk. Every entry in `peasant/source.json` and `peon/source.json` maps to an existing file.

**B2 (No tests for pre-commit hook):** `tests/test-pre-commit-hook.sh` adds 21 tests covering all 9 forbidden characters, 8 allowed-character cases, 2 edge cases (forbidden char in directory only, multiple forbidden chars), and 2 integration tests with real git commits. All pass. The fake-git wrapper approach for testing characters that are illegal on Windows filesystems is well-engineered and makes the tests portable.

**L1-L3 close-out:** The redundant backslash in the regex is cleaned up, the incorrect control-character comment is removed, and the completion checklist reflects actual state.

Additional observations on the fix commit (5ecab16):

- The `basename` to `${file##*/}` change is correct and well-documented. `basename` on MSYS treats backslashes as path separators, which would cause the hook to miss backslash-in-filename violations. Good catch and fix.

- The hook's architecture is sound: `diff --cached --diff-filter=ACR -z` correctly scopes to staged adds/copies/renames with null-delimited output, and `while IFS= read -r -d ''` correctly handles filenames with spaces and special characters.

## BACKLOG

### L1: Hook comments describe an allowlist but implementation is a blocklist

The comment on line 11 ("Allowed characters: ...") and line 19 ("Allowed: a-z A-Z 0-9 space - . _ ' /") describe what sounds like an allowlist, but the `FORBIDDEN_PATTERN` is a blocklist of 9 specific characters. Characters like parentheses, `@`, `#`, `!`, `+`, `=`, etc. are all implicitly allowed. The error message on lines 42-43 has the same gap. This is not wrong behavior-wise (the blocklist approach is reasonable), but the documentation should match the implementation. Either update the comments to say "Rejects filenames containing: ..." or switch to an actual allowlist pattern if the intent is to be restrictive.

### L2: Parentheses allowed in hook but not documented in README

The test suite verifies that parentheses are allowed (`track (1).wav`), and the hook does permit them, but the README's Filename Guidelines section does not list parentheses as allowed. Since the README is contributor-facing, it should reflect what the hook actually permits. The discrepancy could confuse a contributor who reads the README and avoids parentheses unnecessarily, or worse, one who assumes the README is exhaustive and reports a bug when parentheses pass.
