## Task Overview

* **Task Description:** Rename 4 sound files that contain `?` characters in their filenames, making them incompatible with Windows. Update corresponding `source.json` references. This is intended as an upstream PR to `lodev09/claude-sounds`.
* **Motivation:** Windows does not allow `?` in filenames. When cloning the repo on Windows, these files fail to check out, leaving them permanently deleted in the working tree. The `?` characters are part of the voice line dialogue (e.g., "more work?") — not functional.
* **Scope:** 4 `.wav` files across `sounds/peasant/` and `sounds/peon/`, plus their `source.json` mappings.
* **Related Work:** N/A — first contribution to this repo.
* **Estimated Effort:** 30 minutes

**Required Checks:**
* [x] **Task description** clearly states what needs to be done.
* [x] **Motivation** explains why this work is necessary.
* [x] **Scope** defines what will be changed.

### Required Reading

| File | Purpose |
| :--- | :--- |
| `sounds/peasant/source.json` | Event-to-filename mapping for peasant sounds |
| `sounds/peon/source.json` | Event-to-filename mapping for peon sounds |
| `bin/play.sh` | Sound playback script — reads `source.json` dynamically, no hardcoded filenames |

### Renames

| Directory | Old Filename | New Filename | Reason |
| :--- | :--- | :--- | :--- |
| `sounds/peasant/` | `more work?.wav` | `more work.wav` | Remove `?` |
| `sounds/peasant/` | `yes, milord?.wav` | `yes milord.wav` | Remove `?` and `,` |
| `sounds/peon/` | `what you want?.wav` | `what you want.wav` | Remove `?` |
| `sounds/peon/` | `yes?.wav` | `yes.wav` | Remove `?` |

---

## Work Log

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Review Current State** | 4 files with `?` in names fail checkout on Windows. `play.sh` resolves filenames from `source.json` at runtime — no other code references filenames directly. | - [x] Current state is understood and documented. |
| **2. Plan Changes** | Use `gh api` (Git Trees API) to rename files + edit source.json in one atomic commit on a fork, then PR upstream. | - [x] Change plan is documented. |
| **3. Make Changes** | Fork repo, create branch, build new tree with renames + updated source.json blobs, commit, push | - [x] Changes are implemented. |
| **4. Test/Verify** | Clone fork on Windows, verify all files check out. Validate source.json parses and filenames match. | - [x] Changes are tested/verified. |
| **5. Update Documentation** | N/A — no docs reference individual filenames | - [x] Documentation is updated [if applicable]. |
| **6. Review/Merge** | PR to `lodev09/claude-sounds` via `gh pr create` | - [x] Changes are reviewed and merged. |

#### Work Notes

> The `?` characters are part of Warcraft voice line dialogue (peasant saying "More work?", peon saying "Yes?"). They're cosmetic in the filename — removing them doesn't affect functionality since `play.sh` picks a random file from the `source.json` list.

**Commands/Scripts Used:**
```bash
# 1. Fork the repo
gh repo fork lodev09/claude-sounds --clone=false

# 2. Get base tree SHA from main branch
gh api repos/YOURUSER/claude-sounds/git/ref/heads/main

# 3. Create branch for the PR
gh api repos/YOURUSER/claude-sounds/git/refs -f ref=refs/heads/fix-windows-filenames -f sha=COMMIT_SHA

# 4. Get current tree SHA
gh api repos/YOURUSER/claude-sounds/git/commits/COMMIT_SHA

# 5. Build new tree with renames (existing blob SHAs at new paths) + updated source.json blobs
gh api repos/YOURUSER/claude-sounds/git/trees -f base_tree=TREE_SHA ...

# 6. Create commit on the new tree
gh api repos/YOURUSER/claude-sounds/git/commits -f message="..." -f tree=NEW_TREE_SHA -f "parents[]=COMMIT_SHA"

# 7. Update branch ref
gh api repos/YOURUSER/claude-sounds/git/refs/heads/fix-windows-filenames -X PATCH -f sha=NEW_COMMIT_SHA

# 8. Open PR against upstream
gh pr create --repo lodev09/claude-sounds --head YOURUSER:fix-windows-filenames --title "..." --body "..."
```

**Decisions Made:**
* Drop `?` from all filenames — it's the only Windows-illegal character present
* Also drop `,` from "yes, milord?" for cleaner filenames
* Keep spaces in filenames to match the existing convention in the repo
* Use `gh api` with Git Trees API to do all renames in a single atomic commit from Windows — avoids needing Linux/macOS since files don't exist on Windows disk

**Issues Encountered:**
* Files cannot be checked out on Windows, so local `git mv` is impossible — using GitHub's Git Data API via `gh api` instead

---

## Completion & Follow-up

| Task | Detail/Link |
| :--- | :--- |
| **Changes Made** | Renamed 4 wav files, updated 2 source.json files |
| **Files Modified** | 6 files: 4 wav renames + 2 source.json edits |
| **Pull Request** | https://github.com/lodev09/claude-sounds/pull/1 |
| **Testing Performed** | Verified source.json parses, filenames resolve, fresh clone on Windows checks out all files |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Related Chores Identified?** | No |
| **Documentation Updates Needed?** | No |
| **Follow-up Work Required?** | No |
| **Process Improvements?** | Repo could add a CI check for cross-platform filename compatibility |
| **Automation Opportunities?** | N/A |

### Completion Checklist

- [x] All planned changes are implemented.
- [x] Changes are tested/verified (tests pass, configs work, etc.).
- [x] Documentation is updated (CHANGELOG, README, etc.) if applicable.
- [x] Changes are reviewed (self-review or peer review as appropriate).
- [x] Pull request is merged or changes are committed.
- [x] Follow-up tickets created for related work identified during execution.


## Review Log

| Review 1 | APPROVAL | d057909e88d82d4361363bb840e029056de54793 | `.gitban/agents/reviewer/inbox/448JW3-448jw3-reviewer-1.md` |
| Router 1 | Routed executor (approval close-out) + planner (1 BACKLOG card: filename normalization & CI check) | — | `.gitban/agents/executor/inbox/448JW3-448jw3-executor-1.md`, `.gitban/agents/planner/inbox/448JW3-448jw3-planner-1.md` |
