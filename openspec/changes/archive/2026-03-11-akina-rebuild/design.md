## Architecture

Retain the existing stack: **Flutter + Supabase + GetX (MVVM)**. The golden glassmorphism theme system carries over unchanged. The data layer, modules, and navigation are rebuilt to match Akina's information architecture.

## Database Schema

### Tables

**organisations**
- `id` uuid PK, `name` text, `created_at` timestamptz

**org_memberships**
- `id` uuid PK, `user_id` uuid FK→auth.users, `organisation_id` uuid FK→organisations, `role` text CHECK (admin/member), `created_at` timestamptz
- UNIQUE(user_id, organisation_id)

**items**
- `id` uuid PK, `organisation_id` uuid FK, `name` text, `item_number` int (auto-increment per org), `status` text CHECK (storage/in_project/missing/under_repair/retired), `project_id` uuid FK→projects nullable, `qr_code` uuid DEFAULT gen_random_uuid(), `notes` text, `created_at` timestamptz, `updated_at` timestamptz
- UNIQUE(organisation_id, item_number), UNIQUE(qr_code)

**projects**
- `id` uuid PK, `organisation_id` uuid FK, `name` text, `location` text, `status` text CHECK (active/completed/archived), `created_at` timestamptz

**activity_log**
- `id` uuid PK, `organisation_id` uuid FK, `user_id` uuid FK, `action` text, `entity_type` text, `entity_id` uuid, `from_status` text, `to_status` text, `project_id` uuid, `metadata` jsonb, `created_at` timestamptz

### RLS Strategy
- All tables use `get_active_org_id()` helper (reads from org_memberships for auth.uid())
- Items, projects, activity_log: SELECT/INSERT/UPDATE scoped to active org
- org_memberships: users can see memberships for orgs they belong to
- Role checks for admin-only mutations via `get_user_role()` helper

### RPC Functions
- `perform_relocation(item_id, target_status, project_id?)` — atomic status update + activity log
- `perform_onboarding(org_name, full_name)` — create org + membership + seed data
- `complete_project(project_id, action)` — handle items on project completion
- `next_item_number(org_id)` — return next auto-increment number for org

## Module Structure

```
lib/app/modules/
  auth/           — login, signup, onboarding (org creation), Google Sign-In
  shell/          — 5-tab scaffold (Dashboard/Items/Scan/Projects/Account)
  dashboard/      — summary cards, recent activity, active projects, scan shortcut
  items/          — item list (filter/search), item detail (QR, status, history, relocate)
  scan/           — camera scanner + HID input, mode selection, relocate sheet
  projects/       — project list, project detail (assigned items, add/remove)
  account/        — profile, org switcher, members, settings, logout
  relocate/       — shared relocate bottom sheet (used by scan + item detail)
```

## Data Layer

```
lib/app/data/
  models/         — Organisation, OrgMembership, Item, Project, ActivityLog
  providers/      — Thin Supabase query layer per model (5 providers)
  repositories/   — Business logic per model (5 repositories)
  services/       — SupabaseService, ScannerService (camera + HID)
```

## Navigation

| Route | Module | Auth | Notes |
|-------|--------|------|-------|
| /login | auth | no | Email/password + Google Sign-In |
| /signup | auth | no | Create account |
| /onboarding | auth | yes | Create or join org |
| /shell | shell | yes | 5-tab container |
| /item/:id | items | yes | Item detail |
| /project/:id | projects | yes | Project detail |
| /scan | scan | yes | Also accessible from tab |

## Scanner Architecture

The ScannerService handles both input sources:
- **Camera**: MobileScanner widget, returns barcode string
- **HID**: RawKeyboardListener on hidden TextField, buffers rapid keystrokes (<50ms apart), fires on Enter

Both sources → resolve item by qr_code UUID → apply scanner mode logic → trigger relocate flow.

Scanner mode stored in SharedPreferences. Quick Mode default action also stored locally.

## Key Technical Decisions

1. **Item number auto-increment**: Use `next_item_number` RPC that does `SELECT COALESCE(MAX(item_number), 0) + 1` within a transaction
2. **Active org context**: Store `active_org_id` in SharedPreferences + reactive GetX observable. All queries filter by this.
3. **Relocate as shared widget**: `RelocateSheet` is a reusable bottom sheet invoked from both Scan and Item Detail
4. **QR generation**: Use `qr_flutter` package, render in item detail. Print via `printing` package or system share.
5. **Realtime**: Subscribe to items and activity_log tables for live dashboard updates
6. **Role enforcement**: UI hides admin controls for members. RLS policies enforce server-side. `get_user_role()` SQL helper.

## Dependencies

Keep: `get`, `supabase_flutter`, `mobile_scanner`, `google_sign_in`, `flutter_dotenv`, `intl`, `shimmer`, `shared_preferences`, `permission_handler`
Add: `qr_flutter` (QR generation)
Remove: `cached_network_image` (unused)
