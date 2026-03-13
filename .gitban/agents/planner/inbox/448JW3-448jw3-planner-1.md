The reviewer flagged 2 non-blocking items, grouped into 1 card below.
Create ONE card per group. Do not split groups into multiple cards.
The planner is responsible for deduplication against existing cards.

### Card 1: Normalize filenames and add cross-platform filename CI check
Type: BACKLOG
Sprint: none
Files touched: sounds/peasant/*.wav, sounds/peon/*.wav, source.json files, CI config (new)
Items:
- L1: The repo still has filenames with commas (e.g., `off i go, then.wav`). While commas are legal on Windows, they can cause issues with certain shell scripts and tools that use comma as a delimiter. Consider normalizing all filenames to only contain alphanumerics, spaces, hyphens, and dots, and updating source.json references accordingly.
- L2: Add a CI check for cross-platform filename compatibility to prevent future regressions. The card itself noted this as a process improvement opportunity.
