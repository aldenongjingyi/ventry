# Ventry - Product Spec

> Equipment tracking for field teams. Know where every item is, who moved it, and when.

## Overview

Ventry helps teams track physical equipment (gear, tools, inventory) across projects and locations. Teams scan items to move them between storage and projects, with a full audit trail. Multi-tenant — each organisation is isolated with role-based access and plan-based limits.

**Scanning:** Currently QR code-based. May evolve to barcodes or RFID for larger teams and faster workflows.

**Target users:** Film/production crews, event companies, rental houses, construction teams — anyone managing shared physical equipment across jobs.

---

## Architecture

- **Stack:** Flutter + Supabase + GetX (MVVM)
- **Auth:** Email/password, Google OAuth, OTP email verification
- **Multi-tenancy:** `organisations` table with RLS. Users can belong to multiple orgs (Pro).
- **Realtime:** Supabase realtime enabled on items, projects, activity_log (not yet wired to UI)

---

## Data Model

### Organisations
- `name`, `plan` (free/pro)
- Root tenant — all other entities scoped by `organisation_id`

### Org Memberships
- Links users to orgs with `role` (admin/member)
- `full_name` denormalized for display
- Unique constraint: one membership per user per org

### Org Invites
- `code` (8-char alphanumeric), `max_uses`, `use_count`, `expires_at`, `is_active`
- `created_by` (FK to `auth.users`) — tracks which admin generated the code
- Created by admins, accepted via RPC

### Items
- `organisation_id` (FK) — direct tenant anchor, ensures items in storage are still org-scoped
- `name`, `item_number` (auto-increment per org), `status`, `project_id`, `qr_code`, `notes`
- Statuses: `storage`, `in_project`, `missing`, `under_repair`, `retired`
- QR code is a UUID, globally unique
- `item_number` auto-increment: handled via `next_item_number(org_id)` RPC using `MAX + 1` — works for low concurrency but susceptible to race conditions under heavy parallel inserts

### Projects
- `organisation_id` (FK) — direct tenant anchor
- `name`, `location`, `status`
- Statuses: `active`, `completed`, `archived`
- Completing a project can: return items to storage, retire them, or leave them as-is

### Activity Log
- Append-only audit trail — **always written on all plans** (storage is cheap, preserves history for upgrades)
- `user_id` (FK to `auth.users`) — who performed the action
- `organisation_id`, `action`, `entity_type`, `entity_id`, `from_status`, `to_status`, `project_id`, `metadata`
- Joined with `org_memberships` for display names
- **UI gating:** Free shows "upgrade to view history" prompt. Pro shows full history.

---

## Plans & Limits

Ship with **two plans only** — Free and Pro. Validate real usage patterns before adding tiers.

|                    | Free       | Pro        |
|--------------------|------------|------------|
| Members            | 5          | unlimited  |
| Items              | 50         | unlimited  |
| Projects           | 3          | unlimited  |
| Activity log       | always written, UI hidden | full history |
| CSV export         | -          | yes        |
| Multi-org          | -          | yes        |
| Web dashboard      | yes        | yes        |
| Industrial scanner | -          | yes        |

**Multi-org** means a single user can belong to multiple organisations (the memberships table already supports this). It does not mean one account can own/create multiple orgs on Free — that's gated. No billing complexity.

**Web dashboard** is available on all plans. Feature-gate what's inside (exports, analytics) rather than blocking desktop access entirely — admins need to review inventory at a desk.

**Activity log** is always written to the database regardless of plan. Free users see an "upgrade to view history" prompt in the UI. This preserves the audit trail so history is immediately available on upgrade.

### Not in active plans (future, behind "contact us")
These features are designed but not exposed in self-serve plans yet:
- Bulk import
- API access
- SSO

### Limit enforcement
- Server-side via `check_org_limit` RPC (called in RLS INSERT policies)
- **Performance note:** `check_org_limit` does a `COUNT(*)` on every INSERT. Fine at current scale. If it becomes a bottleneck, switch to a counter column on `organisations` incremented/decremented via trigger — makes the RLS check a simple integer comparison.
- UI shows warnings at 80% usage and disables add buttons at 100%
- **Counts must reflect deletions** — deleting or retiring items must decrement the count so users aren't stuck at the limit after cleanup

---

## Screens & Navigation

### Auth Flow
| Screen | Route | Purpose |
|--------|-------|---------|
| Login | `/login` | Email/password + Google sign-in |
| Signup | `/signup` | Name + email + password |
| Verify OTP | `/verify-otp` | 8-digit email confirmation code |
| Onboarding | `/onboarding` | Create org or join via invite code (first-time users with zero memberships) |
| No Organisation | `/no-organisation` | Minimal create/join screen for returning users with zero memberships |
| Join Invite | `/join/:code` | Accept invite from deep link |

### Shell (Main App)
Bottom nav with 4 tabs + center FAB (scan opens as full-screen modal):

| Tab | Screen | Route | Description |
|-----|--------|-------|-------------|
| Items | `ItemsListView` | `/items` | Searchable/filterable item list |
| Projects | `ProjectsListView` | `/projects` | Stats header + active/completed/archived sections (default landing tab) |
| [FAB] | `ScanView` | modal | QR scanner (full-screen dialog, not a tab) |
| Members | `MembersView` | `/members` | View/manage org members, invite (admin) |
| Account | `AccountView` | `/account` | Profile, org, usage, settings |

### Detail / Sub-screens
| Screen | Route | Purpose |
|--------|-------|---------|
| Item Detail | `/items/:id` | Full item info, QR code, relocate, activity history |
| Project Detail | `/projects/:id` | Project info, assigned items, complete/archive |
| Scan Result | `/scan/result` | Scan result display (found/wrong-org/unknown) |
| About | `/account/about` | App info |
| Scanner Settings | `/account/scanner-settings` | Sound, vibration, auto mode toggles |
| Upgrade | `/upgrade` | Plan comparison, usage stats, upgrade CTA |

---

## Features - Built

### Core
- [x] Email/password authentication
- [x] Google OAuth sign-in
- [x] Email OTP verification
- [x] Multi-tenant organisations with RLS
- [x] Role-based access (admin/member)
- [x] Plan-based limits (enforced server-side + UI gating)
- [x] Onboarding flow (create org or join via invite)
- [x] Deep link invite handling (`ventry.app/invite/{code}`)
- [x] Org switching (stored preference per user)

### Items
- [x] Create items (admin only, auto-numbered)
- [x] View item list with search and status filters
- [x] Item detail with QR code display
- [x] Relocate items (storage, project, missing, repair)
- [x] Delete items (admin only)
- [x] Item activity history timeline

### Projects
- [x] Create projects with name and optional location
- [x] View projects in sections (active/completed/archived)
- [x] Project detail with assigned items list
- [x] Complete project (return to storage / retire / leave)
- [x] Archive projects
- [x] Delete projects (admin only)

### Scanning
- [x] QR code scanning via camera
- [x] Scan result card with item info
- [x] Relocate directly from scan result

### Account & Team
- [x] Profile display (name, email)
- [x] Org info with plan badge
- [x] Usage display (members/items/projects with progress bars)
- [x] Generate invite codes (admin)
- [x] Copy invite code + deep link
- [x] View/manage members (admin: toggle role, remove)
- [x] Switch between orgs
- [x] Join additional orgs via code
- [x] Sign out

### Projects Tab (merged from Dashboard)
- [x] Stat cards header (total, storage, in project, missing)
- [x] Projects list with sections (active/completed/archived)

---

## Features - Not Yet Built

### High Priority
- [x] Activity log: always write, gate viewing in UI (Free shows upgrade prompt)
- [ ] Bulk move (select multiple items, move to a different status/project/storage in one action)
- [x] Persist scanner settings (saved to SharedPreferences)
- [x] Wire up realtime subscriptions (items, projects, members)
- [x] Extract shared `GoldButton` widget (moved to `lib/app/widgets/gold_button.dart`)
- [ ] Batch scanning (scan multiple items in sequence)

### Medium Priority
- [ ] CSV export (plan-gated, Pro)
- [ ] Item photos/attachments
- [ ] Item categories/tags
- [ ] Project date range (start/end dates)
- [ ] Search within projects
- [ ] Notifications (items marked missing, project completed)
- [ ] Print QR labels (generate printable sheets)
- [ ] Bulk item creation
- [ ] Item templates (pre-defined item types)
- [ ] `assigned_to` on items (track who has physical possession)
- [ ] Update display name in account settings

### Lower Priority
- [ ] Web dashboard (available all plans, feature-gate exports/analytics)
- [ ] Industrial scanner support (plan-gated, Pro)
- [ ] Offline mode with sync
- [ ] Item condition tracking
- [ ] Item maintenance scheduling
- [ ] Custom fields per org
- [ ] Reports & analytics
- [ ] Stripe integration for plan upgrades

---

## Bulk Move

### Overview
Bulk move allows users to select multiple items and move them to a different status, project, or storage in a single action. It complements scanning — both coexist. Bulk move is for situations where physically scanning every item is impractical (e.g. closing out a project, returning gear after an event).

### Entry Points
1. Long-press any item in ItemsListView to enter multi-select mode on the list
2. "Bulk Move" button on ProjectDetailView (for moving all or some items out of a project)
3. Secondary FAB action alongside Scan (a "list" or "checklist" icon, opens bulk move flow directly)

### Selection UI
When multi-select mode is active on ItemsListView:
- Checkboxes appear on all item rows
- Tapping an item toggles selection
- A sticky bottom action bar appears showing: "[N] items selected" and a "Move" button
- A "Select All" button appears in the app bar (respects any active filters)
- Tapping the app bar back button or "Cancel" exits multi-select mode and clears selection
- Do not navigate away from the list during selection

### Filtering Before Selection
Before or during selection, the user can filter items by:
- Current status (storage, in_project, missing, under_repair, retired)
- Current project
- "Select All" only selects items matching the active filter, not the entire org inventory

### Move Destinations
When the user taps "Move", show a bottom sheet with destination options:
- Storage (sets status to storage, clears project_id)
- A project (sets status to in_project, sets project_id — show a searchable list of active projects)
- Missing (sets status to missing)
- Under Repair (sets status to under_repair)
- Retired (sets status to retired)

Only show destinations that make sense given the selected items' current statuses.

### Confirmation Step
After selecting a destination, show a confirmation sheet:
- "Move [N] items to [Destination]?"
- Scrollable list of the selected item names so the user can verify
- Confirm and Cancel buttons
- On confirm, execute the move

### Data Changes on Confirm
For each selected item:
- Update status and project_id (or null if moving to storage) in the items table
- Insert a row into the activity log with:
  - action: "bulk_move"
  - entity_type: "item"
  - entity_id: item id
  - from_status: previous status
  - to_status: new status
  - project_id: destination project id (if applicable)
  - performed_by: current membership id
  - metadata: include a shared batch_id (a single UUID generated once for the entire bulk action)

Use a Supabase transaction or batch RPC. Do not fire individual updates in a loop without batching.

### Schema Addition
- Add `batch_id UUID nullable` column to `activity_log` if it does not exist

### Permissions
- Any org member can perform bulk moves
- Moves are scoped to the current organisation via existing RLS policies

### Post-Move UI
After a successful bulk move:
- Exit multi-select mode
- Refresh the item list
- Show a snackbar: "[N] items moved to [Destination]"
- Snackbar has an "Undo" action (within 5 seconds) that reverses the move using the batch_id

### Error Handling
- If the transaction fails, roll back all changes (no partial apply)
- If the user's plan limit would be exceeded, block the action and show the upgrade prompt (`/upgrade`)

---

## Roles & Permissions

| Action | Admin | Member |
|--------|-------|--------|
| View items/projects/activity | yes | yes |
| Relocate items | yes | yes |
| Create items | yes | no |
| Delete items | yes | no |
| Create projects | yes | no |
| Complete/archive/delete projects | yes | no |
| Manage members | yes | no |
| Generate invites | yes | no |
| Update org | yes | no |

---

## Data Model — Known Tradeoffs & Gaps

### Deliberate tradeoffs (acceptable for now)
- **`full_name` denormalized on memberships** — will drift if user updates their name in auth. Fine for v1. Consider exposing an "update display name" action in account settings, or syncing on login.
- **Plan limits hardcoded in `check_org_limit` RPC** — no `plans` config table. Works while plans are static. If limits need to change per-org (custom deals, trials), will need a `plan_limits` table or per-org overrides.
- **`item_number` via `MAX + 1` RPC** — not safe under high-concurrency parallel inserts. Fine for current scale. If it becomes an issue, options: counter column on `organisations` incremented in a transaction, or an `org_item_sequences` table.
- **`check_org_limit` in RLS policies** — does `COUNT(*)` on every INSERT. Fine at current scale. Upgrade path: counter columns on `organisations` with trigger-based increment/decrement.

### Gaps to address
- **No `assigned_to` on items** — can't track who has physical possession of an item. Would be a `user_id` FK (nullable). Important for accountability in larger teams.
- **No CHECK constraint enforcing status/project_id consistency** — if `status = 'in_project'` then `project_id` should be NOT NULL, and vice versa. Currently only enforced in the `perform_relocation` RPC logic, not at the DB level. Should add: `CHECK ((status = 'in_project') = (project_id IS NOT NULL))`

---

## Known Issues / Tech Debt
- `handle_new_user` trigger is a no-op placeholder
