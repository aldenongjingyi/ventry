## 1. SupabaseService & Data Layer

- [x] 1.1 Update `SupabaseService` to key stored org by user ID (`active_org_{userId}`) instead of a global key
- [x] 1.2 Add `orgUsage` observable to `SupabaseService` and a `loadOrgUsage()` method calling `get_org_usage` RPC
- [x] 1.3 Add `getAllMemberships()` method to `SupabaseService` that fetches all user memberships with org details
- [x] 1.4 Add `switchOrg(orgId, orgName, role, plan)` method that updates context, persists, and triggers controller reloads
- [x] 1.5 Add `pendingInviteCode` observable to `SupabaseService` for deep link deferred invites

## 2. Auth Flow (Multi-Org Picker)

- [x] 2.1 Update `_checkMembershipAndNavigate` in `AuthController` to fetch all memberships instead of `maybeSingle`
- [x] 2.2 Add org picker bottom sheet shown when user has >1 membership and no stored preference
- [x] 2.3 Auto-select stored org if user is still a member; clear and show picker if not
- [x] 2.4 After login, check for `pendingInviteCode` and auto-process it via `accept_invite` RPC

## 3. Org Switching UI

- [x] 3.1 Add "Switch Organisation" tile to `account_view.dart` settings section (visible when user has >1 membership OR is on Pro+)
- [x] 3.2 Create org switcher bottom sheet showing all orgs with name, role badge, and current org highlighted
- [x] 3.3 On org selection, call `SupabaseService.switchOrg()` and show loading state
- [x] 3.4 Reload all shell controllers (`DashboardController`, `ItemsController`, `ProjectsController`, `AccountController`) after switch

## 4. Join Organisation from Account

- [x] 4.1 Add "Join Organisation" tile to `account_view.dart` settings section
- [x] 4.2 Create join org bottom sheet with invite code input field (same glass pattern as invite sheet)
- [x] 4.3 Add multi-org gate: check `orgUsage.features.multi_org` before allowing join; show upgrade prompt if false
- [x] 4.4 On successful join, add new org to membership list and switch to it

## 5. Invite Links

- [x] 5.1 Add `app_links` package to `pubspec.yaml`
- [x] 5.2 Update invite sheet in `account_view.dart` to show "Copy Link" button alongside invite code, copying `https://ventry.app/invite/{code}`
- [x] 5.3 Add deep link listener in `AuthController.onInit()` using `app_links` to handle `https://ventry.app/invite/{code}` URLs
- [x] 5.4 When deep link received while authenticated: show confirmation sheet with org name, then call `accept_invite`
- [x] 5.5 When deep link received while unauthenticated: store code in `pendingInviteCode`, proceed to login
- [x] 5.6 Configure iOS `apple-app-site-association` and Android `assetlinks.json` for universal links

## 6. Plan Limits UI

- [x] 6.1 Call `loadOrgUsage()` in `ShellBinding` or shell controller on init
- [x] 6.2 Add usage card to Account screen showing members/items/projects counts vs limits with visual bars
- [x] 6.3 Add inline limit warnings (amber at 80%, red at 100%) in Items list and Projects list headers
- [x] 6.4 Disable "Add Item" button when item limit reached; show tooltip explaining limit
- [x] 6.5 Disable "Add Project" button when project limit reached
- [x] 6.6 Re-fetch `get_org_usage` after item/project creation in `ItemsController` and `ProjectsController`

## 7. Verification

- [x] 7.1 `flutter analyze` passes with 0 issues
- [x] 7.2 `flutter build apk --debug` succeeds
- [ ] 7.3 Org switch correctly reloads all data for the new org
- [ ] 7.4 Join via invite code from Account works and switches to new org
- [ ] 7.5 Multi-org gate blocks Free/Starter users from joining a second org
- [ ] 7.6 Plan usage displays correctly for Free, Starter, and Pro orgs
- [ ] 7.7 Deep link invite flow works for both authenticated and unauthenticated users
