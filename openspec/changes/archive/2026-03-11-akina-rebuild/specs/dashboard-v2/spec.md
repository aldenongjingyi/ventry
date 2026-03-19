# Dashboard V2

## Overview

The dashboard is the home screen of the app after login. It provides a high-level summary of the active organisation's equipment status, recent activity, and quick access to the scanner.

## Requirements

### Summary Cards

1. Four summary cards are displayed at the top of the dashboard:
   - **Total Items**: count of all non-retired items in the org.
   - **In Storage**: count of items with status `storage`.
   - **In Project**: count of items with status `in_project`.
   - **Missing**: count of items with status `missing`.
2. Each card shows a label and a count number. Tapping a card navigates to the item list pre-filtered by that status (except Total, which shows all).
3. Items with status `under_repair` and `retired` are not shown as separate cards but are included in the Total count (under_repair only; retired is excluded from Total).

### Recent Activity

4. Below the summary cards, a "Recent Activity" section shows the most recent activity log entries for the org, newest first.
5. The default page size is 20 entries. A "View all" link navigates to a full activity log screen.
6. Each entry displays: actor name, action description, item/project name, and relative timestamp.
7. Tapping an entry navigates to the relevant item or project detail screen.

### Active Projects

8. Below recent activity, an "Active Projects" section lists all projects with status `active`.
9. Each project row shows the project name, location (if set), and the count of items currently assigned.
10. Tapping a project navigates to the project detail screen.
11. If no active projects exist, a placeholder message is shown.

### Quick Actions

12. A floating action button (FAB) labeled "Scan" is always visible on the dashboard. Tapping it opens the scanner screen.
13. The FAB uses the app's primary color and a QR code icon.

### Refresh

14. Pull-to-refresh reloads all dashboard data: summary counts, recent activity, and active projects.
15. Dashboard data also refreshes automatically via Supabase Realtime subscriptions on the items and projects tables.

## Data Model

No new tables. The dashboard reads from items, projects, and activity_log.

## Behavior

- Summary counts are computed via aggregate queries scoped to the active org. Retired items are excluded from all four cards.
- Under repair items contribute to the Total count but do not have a dedicated card.
- If the user has no items in the org, the summary cards all show 0 and a prompt to add items is shown.
- The dashboard loads summary cards first, then recent activity and projects in parallel, to minimize perceived load time.
- Real-time updates increment/decrement summary counts without a full reload.
