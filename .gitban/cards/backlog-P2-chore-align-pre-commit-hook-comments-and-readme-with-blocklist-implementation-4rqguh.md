# Align pre-commit hook comments and README with blocklist implementation

## Task Overview

* **Task Description:** Update hook comments and README to accurately reflect the filename validation implementation. The pre-commit hook uses a blocklist of 9 specific characters, but comments describe an allowlist. The README Filename Guidelines section does not list parentheses as allowed, even though the hook permits them.
* **Motivation:** Contributors reading the hook comments or README will get a misleading picture of what filenames are allowed, causing confusion. Comments and docs should match the actual implementation.
* **Scope:** `hooks/pre-commit-filename-check.sh`, `README.md`
* **Related Work:** Review feedback from dispatch n7g12q
* **Estimated Effort:** 30 minutes

**Required Checks:**
* [x] **Task description** clearly states what needs to be done.
* [x] **Motivation** explains why this work is necessary.
* [x] **Scope** defines what will be changed.

---

## Work Log

Track the execution of this chore task step by step. Add or remove steps as needed for your specific task.

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Review Current State** | Hook comments on lines 11, 19, and error message on lines 42-43 describe an allowlist ("Allowed characters: ...") but the implementation is a blocklist of 9 specific characters. Parentheses are allowed by the hook (and tested) but not listed in README. | - [ ] Current state is understood and documented. |
| **2. Plan Changes** | (a) Update hook comments to say "Rejects filenames containing: ..." or switch to an actual allowlist pattern. (b) Update README Filename Guidelines to list parentheses as allowed. | - [ ] Change plan is documented. |
| **3. Make Changes** | | - [ ] Changes are implemented. |
| **4. Test/Verify** | | - [ ] Changes are tested/verified. |
| **5. Update Documentation** | | - [ ] Documentation is updated [if applicable]. |
| **6. Review/Merge** | | - [ ] Changes are reviewed and merged. |

#### Work Notes

> Two items from review feedback grouped into this single card:
> - L1: Hook comments describe an allowlist but the implementation is a blocklist. Update comments to match.
> - L2: Parentheses are allowed by the hook but not listed in README Filename Guidelines.

**Commands/Scripts Used:**
```bash
# N/A - manual edits
```

**Decisions Made:**
* Pending: decide whether to update comments to describe the blocklist, or refactor the hook to use an actual allowlist pattern.

**Issues Encountered:**
* None yet.

---

## Completion & Follow-up

| Task | Detail/Link |
| :--- | :--- |
| **Changes Made** | |
| **Files Modified** | `hooks/pre-commit-filename-check.sh`, `README.md` |
| **Pull Request** | |
| **Testing Performed** | |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Related Chores Identified?** | No |
| **Documentation Updates Needed?** | Yes - README update is part of this card |
| **Follow-up Work Required?** | No |
| **Process Improvements?** | N/A |
| **Automation Opportunities?** | N/A |

### Completion Checklist

* [ ] All planned changes are implemented.
* [ ] Changes are tested/verified (tests pass, configs work, etc.).
* [ ] Documentation is updated (CHANGELOG, README, etc.) if applicable.
* [ ] Changes are reviewed (self-review or peer review as appropriate).
* [ ] Pull request is merged or changes are committed.
* [ ] Follow-up tickets created for related work identified during execution.
