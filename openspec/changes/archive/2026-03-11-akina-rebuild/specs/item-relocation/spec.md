# Item Relocation

## Overview

Relocation is the core action of the app: changing an item's status and optionally its assigned project. It can be triggered by scanning a QR code or from the item detail screen. Every relocation is logged.

## Requirements

1. Relocation changes an item's `status` and optionally its `project_id` in a single atomic operation.
2. The Relocate Sheet presents the available destination options based on the item's current status.
3. Available relocation options are:
   - **Move to Storage** -- sets status to `storage`, clears project_id.
   - **Assign to Project** -- sets status to `in_project`, requires the user to select a target project from active projects.
   - **Mark Missing** -- sets status to `missing`, preserves current project_id.
   - **Mark Under Repair** -- sets status to `under_repair`, preserves current project_id.
4. Only options that represent an actual state change are shown (e.g., an item already in storage does not see "Move to Storage").
5. The relocation writes to the items table and inserts an activity_log entry in the same database transaction (Supabase RPC).
6. Both admins and members can relocate items.
7. Retired items cannot be relocated. If a retired item is scanned, display a message indicating the item is retired and no actions are available.
8. After successful relocation, the UI shows a confirmation with the new status. In Quick Mode, this is a toast with an undo option.

## Data Model

No new tables. Relocation modifies `items.status` and `items.project_id` and inserts into `activity_log`.

## Behavior

- The Relocate Sheet is a bottom sheet that slides up from the bottom of the screen.
- When "Assign to Project" is selected, a secondary picker displays the list of active projects in the org. If no active projects exist, show a message and disable this option.
- If two users relocate the same item concurrently, the last write wins. The activity log preserves both entries with accurate `from_status` values captured at read time.
- Undo (in Quick Mode) reverses the relocation by applying the inverse status/project change and appending another activity log entry (not by deleting the original).
- Scanning an unrecognized QR code (UUID not found in items for the active org) displays an "Item not found" error.
- Scanning a QR code belonging to a different org displays the same "Item not found" error (no cross-org data leakage).
