Activate your venv first: `.\.venv\Scripts\Activate.ps1`

The code for the gitban card with id 448jw3 has been approved as of commit d057909e88d82d4361363bb840e029056de54793. Please use the gitban tools to update the gitban card and begin the tasks required to properly complete it.

## Card Close-out tasks:
- Use gitban's checkbox tools to ensure all checkboxes on the card are checked off for completed work if not already.
- Do not mark any work as deferred. This card will be closed and archived and likely never seen again.
- Use gitban's complete card tool to submit and validate if not already completed.
- Close-out items: The "Documentation is updated" checkbox can be checked as N/A per the card (no docs reference individual filenames). The "Changes are reviewed" checkbox should be checked now that the review is complete.
- If this card is not in a sprint, push the feature branch and create a PR to main using `gh pr create`. Do not merge it — the user reviews and merges.

## Sprint Close-out tasks:
- If this is the final card of a sprint, do not merge — the dispatcher handles the sprint PR to main.
