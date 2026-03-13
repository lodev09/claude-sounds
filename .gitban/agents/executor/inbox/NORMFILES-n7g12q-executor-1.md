Activate your venv first: `.\.venv\Scripts\Activate.ps1`

The code for the gitban card with id n7g12q has been REJECTED at review 1. The reviewer identified 2 blockers that must be resolved before re-review.

===BEGIN REFACTORING INSTRUCTIONS===

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

===END REFACTORING INSTRUCTIONS===

## Close-out items (non-blocking, fix while you are in there)

These are trivial fixes from backlog items that touch code you are already modifying:

- **L1:** The `FORBIDDEN_PATTERN` regex in the pre-commit hook includes `\` twice in the character class (once via `\"` and once via `\\`). Clean up the redundancy for readability.
- **L2:** Line 8 of the hook comment says "(and control characters)" but the regex does not match control characters. Either add control character detection or remove the claim from the comment.
- **L3:** The card's completion checklist marks items as done that are not actually done (e.g., "Changes are tested/verified" and "Pull request is merged"). Use gitban tools to uncheck those boxes so the card reflects actual state.
