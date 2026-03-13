The reviewer flagged 2 non-blocking items, grouped into 1 card below.
Create ONE card per group. Do not split groups into multiple cards.
The planner is responsible for deduplication against existing cards.

### Card 1: Align pre-commit hook comments and README with blocklist implementation
Type: BACKLOG
Sprint: none
Files touched: hooks/pre-commit-filename-check.sh, README.md
Items:
- L1: Hook comments on lines 11, 19, and error message on lines 42-43 describe an allowlist ("Allowed characters: ...") but the implementation is a blocklist of 9 specific characters. Update comments to say "Rejects filenames containing: ..." or switch to an actual allowlist pattern.
- L2: Parentheses are allowed by the hook (and tested), but the README Filename Guidelines section does not list them as allowed. Update README to reflect what the hook actually permits so contributors are not confused.
