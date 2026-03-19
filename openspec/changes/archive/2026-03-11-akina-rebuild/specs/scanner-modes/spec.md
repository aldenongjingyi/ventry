# Scanner Modes

## Overview

The scanner supports three interaction modes that control how much user input is required after scanning a QR code. The user selects their preferred mode in app settings. The mode affects post-scan behavior only; the scan mechanism itself is identical across modes.

## Requirements

1. Three scanner modes are available: Quick, Smart, and Manual.
2. The active mode is stored in local user preferences (persisted across sessions).
3. The default mode for new users is Smart.
4. The mode can be changed in the account/settings screen at any time.

### Quick Mode

5. After scanning, the app automatically applies a preset default action with zero additional taps.
6. The default action is configurable by the user (e.g., "Move to Storage", "Assign to Project X", "Mark Missing").
7. On success, a toast notification appears showing the item name and new status, with an Undo button visible for 5 seconds.
8. Tapping Undo reverses the relocation immediately (see item-relocation spec for undo behavior).
9. If the default action cannot be applied (e.g., item already in that status, item is retired), the app falls back to Smart Mode for that scan.

### Smart Mode

10. After scanning, the app displays an item summary card overlaid on the camera view, showing item name, item number, current status, and current project.
11. Below the summary card, a single suggested action button is shown. The suggestion is the most likely next action based on current status (e.g., an item in storage suggests "Assign to Project"; an item in a project suggests "Move to Storage").
12. Tapping the suggested action executes it (with a project picker if needed).
13. A secondary "More options" link opens the full Relocate Sheet (Manual Mode behavior).

### Manual Mode

14. After scanning, the full Relocate Sheet opens immediately with all available relocation options for the scanned item.
15. The user selects an action manually.

## Behavior

- The scanner screen shows a small indicator of the current mode (e.g., icon or label in the corner).
- Mode switching does not interrupt an active scan session.
- If the scanned QR code is unrecognized or belongs to a retired item, all three modes display the same error state (no mode-specific differences for error cases).
- Smart Mode suggestion logic: `storage` -> "Assign to Project", `in_project` -> "Move to Storage", `missing` -> "Move to Storage", `under_repair` -> "Move to Storage".
