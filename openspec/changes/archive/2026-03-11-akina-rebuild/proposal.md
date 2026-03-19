## Why

The current Lumalight app was built as a generic equipment checkout/checkin system. The app needs to be rebuilt as **Akina** — a purpose-built equipment tracking app for field teams that bring gear to external job sites. The key differentiator is QR-code-driven item relocation with configurable scan modes (Quick/Smart/Manual), multi-organisation support, and a role-based access model (admin/member). This rebuild aligns the data model, navigation, and workflows with real field-team usage patterns.

## What Changes

- **BREAKING**: Rename app from "Lumalight" to "Akina"
- **BREAKING**: Replace `companies` with `organisations` (users can belong to multiple)
- **BREAKING**: Replace `equipment` with `items` (new fields: `item_number`, `qr_code`, simplified statuses: storage/in_project/missing/under_repair/retired)
- **BREAKING**: Remove `equipment_assignments` table — item-to-project is now a direct FK on the item
- **BREAKING**: Remove checkout/checkin wizard flows — replaced by scan-to-relocate flow
- **BREAKING**: Replace 5-tab navigation (Dashboard/Equipment/Scan/Projects/More) with new 5-tab layout (Dashboard/Items/Scan/Projects/Account)
- Add multi-organisation support with org switcher and per-org role-based access
- Add QR code generation per item (client-side using `qr_flutter`)
- Add 3 scanner modes: Quick (zero-tap auto-action), Smart (one-tap suggestion), Manual (full relocate sheet)
- Add HID/Bluetooth barcode scanner support alongside camera scanning
- Add item relocation flow (move to storage, assign to project, mark missing/under repair)
- Add activity log with from_status/to_status tracking
- Add admin-only CRUD for items, projects, and members
- Add organisation member management

## Capabilities

### New Capabilities
- `org-management`: Multi-organisation support — create, switch, manage orgs; user-org membership with roles (admin/member)
- `item-management`: Item CRUD — create/edit/delete items with name, item_number, status, QR code, project assignment, notes
- `item-relocation`: Scan-to-relocate flow — resolve item from QR/barcode, present relocation options based on scanner mode, update status atomically
- `scanner-modes`: Configurable scan behavior — Quick Mode (auto-apply preset action), Smart Mode (contextual suggestions), Manual Mode (full option sheet)
- `hid-scanner`: External Bluetooth/HID barcode scanner support — keyboard wedge input capture, auto-detect vs camera toggle
- `qr-generation`: Client-side QR code generation per item using UUID, full-screen view, print support
- `project-lifecycle`: Project CRUD with item assignment — create/archive/delete projects, assign/remove items, handle cascading actions on project deletion/completion
- `role-access`: Role-based access control — admin gets full CRUD, member gets read + relocate only; enforced in UI and RLS
- `activity-log`: Comprehensive activity logging — who, what, when, from_status, to_status, project context
- `dashboard-v2`: Redesigned dashboard — summary cards (total/storage/in-project/missing), recent activity, active projects with item counts, scan shortcut
- `account-screen`: User profile, org switcher, member management, app settings, logout

### Modified Capabilities
_(none — this is a full rebuild, no existing specs to modify)_

## Impact

- **Database**: Full schema rebuild — new tables (organisations, org_memberships, items, projects, activity_log), new RLS policies scoped to active org, new RPC functions for relocation
- **Models**: All 7 data models replaced with new Akina models
- **Providers/Repositories**: All 6 provider/repository pairs rewritten for new schema
- **Modules**: All 10 modules rebuilt (auth, shell, dashboard, items, scan, projects, account + new relocate flow)
- **Dependencies**: Add `qr_flutter` for QR generation; keep `mobile_scanner`, `google_sign_in`, `supabase_flutter`, `get`
- **Theme**: Retain golden glassmorphism design system — no visual changes needed
- **Auth**: Keep existing Google Sign-In + email/password; add org selection after login
- **API design**: Structure Supabase as platform-agnostic REST (versioned endpoints mindset) for future web app compatibility
