## Phase 1: Database & Foundation

- [ ] Write new Supabase schema SQL (organisations, org_memberships, items, projects, activity_log) with RLS policies and RPC functions
- [ ] Run schema in Supabase SQL Editor (drop old tables or create fresh)
- [ ] Create data models: Organisation, OrgMembership, Item, Project, ActivityLog
- [ ] Create providers: OrgProvider, ItemProvider, ProjectProvider, ActivityProvider, MemberProvider
- [ ] Create repositories: OrgRepository, ItemRepository, ProjectRepository, ActivityRepository, MemberRepository
- [ ] Update SupabaseService with `activeOrgId` reactive state and `get_active_org_id` helper
- [ ] Add `qr_flutter` dependency to pubspec.yaml

## Phase 2: Auth & Onboarding

- [ ] Rename app from Lumalight to Akina (Android manifest, iOS Info.plist, app.dart, main.dart)
- [ ] Update `perform_onboarding` RPC to create organisation + org_membership instead of company + profile
- [ ] Update AuthController for new onboarding flow (create org or join existing)
- [ ] Update onboarding view for org creation
- [ ] Keep Google Sign-In and email/password auth unchanged

## Phase 3: Shell & Navigation

- [ ] Update shell with 5 tabs: Dashboard, Items, Scan, Projects, Account
- [ ] Update app_routes.dart and app_pages.dart with new routes
- [ ] Update shell_controller.dart and shell_view.dart

## Phase 4: Items Module

- [ ] Create ItemController with list, search, filter by status/project
- [ ] Create item list view with glass cards, status badges, search bar
- [ ] Create item detail view: name + item_number, status indicator, assigned project, QR code display, notes, activity history
- [ ] Add relocate action button on item detail (opens RelocateSheet)
- [ ] Add admin-only edit/delete actions on item detail
- [ ] Create add/edit item form (admin only)

## Phase 5: Scanner Module

- [ ] Update ScanController for 3 scanner modes (Quick/Smart/Manual)
- [ ] Update ScanView with camera scanner (MobileScanner)
- [ ] Add HID keyboard wedge input support (hidden TextField + RawKeyboardListener)
- [ ] Add camera/HID toggle in scan view
- [ ] Create RelocateSheet bottom sheet widget (shared between scan + item detail)
- [ ] Implement Quick Mode: auto-apply preset action, toast with undo
- [ ] Implement Smart Mode: item card + suggested action button
- [ ] Implement Manual Mode: full RelocateSheet with all options
- [ ] Handle edge cases: retired item, unrecognised QR, already-in-target-state

## Phase 6: Projects Module

- [ ] Create ProjectsController with list grouped by status
- [ ] Create projects list view (active first, then completed/archived)
- [ ] Create project detail view: name, location, status, assigned items list
- [ ] Add/remove items from project (admin only)
- [ ] Implement project completion flow: prompt for item fate (return to storage / leave / decide individually)
- [ ] Implement project deletion with item fate prompt

## Phase 7: Dashboard

- [ ] Create DashboardController with summary counts, recent activity, active projects
- [ ] Create dashboard view: 4 summary cards (total, storage, in_project, missing)
- [ ] Add recently updated items section
- [ ] Add active projects with item counts
- [ ] Add scan QR shortcut FAB
- [ ] Add Realtime subscriptions for live updates

## Phase 8: Account Module

- [ ] Create AccountController
- [ ] Create account view: profile section (name, email)
- [ ] Add organisation switcher (if user belongs to multiple orgs)
- [ ] Add Members section (admin: view/invite/remove members)
- [ ] Add Manage Items shortcut (admin)
- [ ] Add Manage Projects shortcut (admin)
- [ ] Add Settings section: scanner mode picker, HID toggle, Quick Mode default action
- [ ] Add logout with state cleanup

## Phase 9: QR Code Generation

- [ ] Add QR code display widget using qr_flutter in item detail
- [ ] Add full-screen QR view for scanning by another device
- [ ] Add print/share QR code functionality

## Phase 10: Polish & Verification

- [ ] Ensure golden glassmorphism theme applied consistently to all new screens
- [ ] Run `flutter analyze` — fix all errors and warnings
- [ ] Run `flutter build apk --debug` — verify build succeeds
- [ ] Test full flow: signup → create org → add item → scan QR → relocate → verify dashboard updates
- [ ] Commit and push to GitHub
