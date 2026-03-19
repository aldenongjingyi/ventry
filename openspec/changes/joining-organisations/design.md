## Context

Ventry is a Flutter app using Supabase + GetX. The database already supports multi-org (users can have multiple `org_memberships`), invite codes (`org_invites` table + `accept_invite` RPC), and plan limits (`check_org_limit` function). However, the client currently:

1. Only checks the first membership on login (`LIMIT 1`) and navigates directly to shell
2. Has no UI to switch orgs or join a second org post-onboarding
3. Only generates invite codes — no shareable link flow
4. Doesn't surface plan usage or limits anywhere

The `SupabaseService` holds `activeOrgId` as a singleton observable. All controllers and repositories use this to scope queries. Switching orgs means updating this value and reloading all controller data.

## Goals / Non-Goals

**Goals:**
- Users with multiple memberships can switch between orgs without logging out
- Users can join additional orgs from within the app (via code or link)
- Admins can generate invite links in addition to codes
- Plan limits (members, items, projects) are visible in the UI
- Multi-org gated behind Pro/Enterprise plan

**Non-Goals:**
- Billing/payment integration (out of scope — plan upgrades are manual for now)
- Web dashboard or API access features
- Changing the existing invite code RPC or database schema
- Organisation settings management (rename, delete org)
- Push notifications for org invites

## Decisions

### 1. Org switching via SupabaseService context change
**Decision:** When the user switches orgs, update `SupabaseService.activeOrgId/Name/Plan/Role`, persist the choice to SharedPreferences, then reload all shell controllers by calling their `loadX()` methods.

**Alternatives considered:**
- Full navigation reset (pop to login, re-enter shell): Simpler but worse UX — user loses nav state, feels like re-login
- Separate service per org: Over-engineered for the current app size

**Rationale:** The existing controllers already scope all queries to `activeOrgId`. Switching the ID and triggering reloads is the minimal change. The `ShellBinding` already lazily puts all controllers, so we can find and reload them.

### 2. Org picker on login (multi-membership)
**Decision:** When `_checkMembershipAndNavigate` finds >1 membership, show an org picker bottom sheet instead of auto-selecting the first one. Persist the last-used org so returning users don't see the picker every time.

**Alternatives considered:**
- Always pick the most recently joined org: No user control, confusing
- Separate "org selection" screen as a route: More code, not needed — a bottom sheet is sufficient

### 3. Invite links as deep links with code parameter
**Decision:** Invite links use the format `https://ventry.app/invite/{code}`. On the Flutter side, use `app_links` package to handle incoming URLs. The link simply extracts the code and calls the same `accept_invite` RPC — no new backend endpoint needed.

**Alternatives considered:**
- Custom URI scheme (`ventry://invite/{code}`): Doesn't work on web, less shareable
- Supabase Edge Function for link resolution: Unnecessary complexity — the code is already validated by RPC

**Rationale:** Universal links (https scheme) work across all platforms and are shareable via any messaging app. The invite code is already the source of truth.

### 4. Multi-org gate check
**Decision:** When a user tries to join a second org, check if their current org's plan is Pro or Enterprise. If not, show an upgrade prompt. This check happens client-side before calling `accept_invite`.

**Rationale:** The `get_org_usage` RPC already returns feature flags including `multi_org`. We read this flag from the current org's plan.

### 5. Plan usage display
**Decision:** Call `get_org_usage` RPC once on shell load and expose the result via `SupabaseService`. Display usage bars/counts in the Account screen and show inline warnings when approaching limits (e.g., "28/30 items used").

**Alternatives considered:**
- Fetch usage per-screen: More API calls, stale data risk across screens
- Real-time subscription on usage: Over-engineered for v1

## Risks / Trade-offs

- **Stale org context after switch**: Controllers that hold cached data may show old org's data briefly during reload → Mitigation: Show a loading indicator during org switch, clear lists before reload
- **Deep link handling when not authenticated**: User taps invite link but isn't logged in → Mitigation: Store the pending invite code, proceed through auth, then auto-join after login
- **Multi-org gate is client-side only**: A determined user could call the RPC directly → Mitigation: Acceptable for v1; server-side enforcement can be added later via RPC check
- **SharedPreferences key collision for multi-user device**: Two users on same device could conflict → Mitigation: Key the stored org ID by user ID (`active_org_{userId}`)
