# Normalize filenames and add cross-platform filename CI check

---

## Task Overview

* **Task Description:** Rename sound files that contain commas in their filenames (e.g., `off i go, then.wav`) to only use alphanumerics, spaces, hyphens, and dots. Update corresponding `source.json` references. Additionally, add a CI check that validates filename cross-platform compatibility to prevent future regressions.
* **Motivation:** While commas are legal on Windows, they can cause issues with certain shell scripts and tools that use comma as a delimiter. A CI check would catch problematic filenames before they are merged, preventing recurrence of issues like the `?` character problem addressed in card 448jw3.
* **Scope:** `sounds/peasant/*.wav`, `sounds/peon/*.wav`, corresponding `source.json` files, and CI configuration (new).
* **Related Work:** Follow-up from card 448jw3 (rename-sound-files-with-invalid-windows-characters) review findings.
* **Estimated Effort:** 1-2 hours

**Required Checks:**
* [x] **Task description** clearly states what needs to be done.
* [x] **Motivation** explains why this work is necessary.
* [x] **Scope** defines what will be changed.

---

## Work Log

Track the execution of this chore task step by step. Add or remove steps as needed for your specific task.

| Step | Status/Details | Universal Check |
| :---: | :--- | :---: |
| **1. Review Current State** | Identify all files with commas or other problematic characters in filenames | - [ ] Current state is understood and documented. |
| **2. Plan Changes** | Determine normalized filenames and update mapping for source.json | - [ ] Change plan is documented. |
| **3. Rename Files** | Rename .wav files to remove commas, update source.json references | - [ ] Changes are implemented. |
| **4. Add CI Check** | Add a CI step that validates all filenames for cross-platform compatibility (no ?, *, :, <, >, |, commas, etc.) | - [ ] Changes are implemented. |
| **5. Test/Verify** | Run CI check locally, verify sound playback still works with renamed files | - [ ] Changes are tested/verified. |
| **6. Review/Merge** | Submit PR for review | - [ ] Changes are reviewed and merged. |

#### Work Notes

> Items flagged during review of card 448jw3:
> - L1: Filenames with commas (e.g., `off i go, then.wav`) can break shell scripts and tools using comma as delimiter. Normalize to alphanumerics, spaces, hyphens, and dots.
> - L2: Add a CI check for cross-platform filename compatibility to prevent future regressions.

**Commands/Scripts Used:**
```bash
# Example: Find files with commas
find sounds/ -name '*,*'
```

**Decisions Made:**
* Allowed characters: alphanumerics, spaces, hyphens, dots
* CI check should reject filenames with: ? * : < > | , " and other platform-incompatible characters

**Issues Encountered:**
* None yet

---

## Completion & Follow-up

| Task | Detail/Link |
| :--- | :--- |
| **Changes Made** | Pending |
| **Files Modified** | Pending |
| **Pull Request** | Pending |
| **Testing Performed** | Pending |

### Follow-up & Lessons Learned

| Topic | Status / Action Required |
| :--- | :--- |
| **Related Chores Identified?** | No |
| **Documentation Updates Needed?** | No |
| **Follow-up Work Required?** | No |
| **Process Improvements?** | This card itself implements a process improvement (CI check) |
| **Automation Opportunities?** | The CI check is the automation |

### Completion Checklist

* [ ] All planned changes are implemented.
* [ ] Changes are tested/verified (tests pass, configs work, etc.).
* [ ] Documentation is updated (CHANGELOG, README, etc.) if applicable.
* [ ] Changes are reviewed (self-review or peer review as appropriate).
* [ ] Pull request is merged or changes are committed.
* [ ] Follow-up tickets created for related work identified during execution.

---

### Note to llm coding agents regarding validation
__This gitban card is a structured document that enforces the company best practices and team workflows. You must follow this process and carfully follow validation rules. Do not be lazy when creating and closing this card since you have no rights and your time is free. Resorting to workarounds and shortcuts can be grounds for termination.__
