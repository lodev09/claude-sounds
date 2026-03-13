---
verdict: REJECTION
card_id: n7g12q
review_number: 1
commit: 4599295
date: 2026-03-13
has_backlog_items: true
---

## BLOCKERS

### B1: source.json references non-existent files

The diff updates `peasant/source.json` and `peon/source.json` to remove commas and question marks from filenames, but the corresponding `.wav` files were never renamed on disk. The only actual file rename in this commit is `off i go, then.wav` -> `off i go then.wav`.

After this commit, source.json points to files that do not exist:
- `sounds/peasant/yes milord.wav` (no such file)
- `sounds/peasant/more work.wav` (no such file)
- `sounds/peon/yes.wav` (no such file)
- `sounds/peon/what you want.wav` (no such file)

The prior commit (d7e4b01 / card 448jw3) reportedly renamed the `?`-containing files via the GitHub Git Trees API on the remote, but those renames are not present in the local tree. The source.json edits here assume those renames landed locally, which they did not.

**Refactor plan:** Either (a) include the actual `.wav` file renames in this commit (fetching them from the upstream PR if needed), or (b) revert the source.json changes for files that were not renamed locally and track the remaining renames on a separate card that depends on the upstream PR merging first.

### B2: No tests for the pre-commit hook

The pre-commit hook is new executable code with regex-based validation logic. There is no test that verifies it correctly rejects forbidden characters (`? * : < > | , " \`) and correctly allows valid characters (alphanumerics, spaces, hyphens, dots, underscores, single quotes). A minimal shell-based test that stages files with various names and asserts the hook's exit code would be sufficient.

**Refactor plan:** Add a test script (e.g., `tests/test-pre-commit-hook.sh`) that:
1. Creates a temporary git repo
2. Stages files with forbidden characters and asserts exit code 1
3. Stages files with only allowed characters and asserts exit code 0
4. Tests edge cases (e.g., forbidden chars only in directory components vs. basename)

## BACKLOG

### L1: Hook regex is slightly redundant

The `FORBIDDEN_PATTERN` value `'[?*:<>|,\"\\]'` includes `\` twice in the character class (once via `\"` and once via `\\`). Not harmful, but cleaning it up would improve readability. A clearer approach would be to use a variable like `FORBIDDEN_CHARS='[?*:<>|,"\]'` or document the escaping more explicitly.

### L2: Hook comment claims control character detection that is not implemented

Line 8 of the hook says "(and control characters)" but the `FORBIDDEN_PATTERN` regex does not match control characters. Either add control character detection or remove the claim from the comment.

### L3: Completion checklist on the card is prematurely checked

The card's completion checklist marks "Changes are tested/verified" and "Pull request is merged or changes are committed" as done, but the source.json changes reference files that do not exist, meaning testing could not have verified correct behavior. The checklist should reflect actual state.
