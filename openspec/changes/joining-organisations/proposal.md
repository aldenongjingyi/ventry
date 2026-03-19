## Why

The app currently only supports joining an organisation during initial onboarding via invite code. Users who already belong to one org cannot join additional ones, there's no way to switch between orgs, and the invite flow is limited to codes only (no shareable links). Multi-org support is a Pro feature that needs full client-side implementation.

## What Changes

- Add an "org switcher" so users in multiple orgs can switch active context without logging out
- Add a "Join Organisation" flow accessible from Account (not just onboarding) via invite code or invite link
- Add invite link generation for admins alongside the existing invite code flow
- Add an org picker on login when a user belongs to multiple orgs
- Enforce plan limits on multi-org (only Pro/Enterprise users can belong to >1 org)
- Surface plan limits and usage in the UI (member count, item count, project count vs limits)

## Capabilities

### New Capabilities
- `org-switching`: Ability to switch active organisation context and join additional orgs from within the app
- `invite-links`: Shareable deep links for joining an organisation (complement to invite codes)
- `plan-limits-ui`: Display plan tier, usage stats, and limit warnings throughout the app

### Modified Capabilities
_(none — no existing specs to modify)_

## Impact

- **Auth flow**: `_checkMembershipAndNavigate` must handle multiple memberships (show picker or default to last-used)
- **SupabaseService**: `activeOrgId` switching logic, persist last-used org per user
- **Account module**: New "Switch Org" / "Join Org" UI, invite link generation
- **Shell**: Org name display, possibly org indicator in nav
- **Schema**: No DB changes needed — `org_memberships`, `org_invites`, `accept_invite` RPC, and `check_org_limit` already support multi-org. May need a new RPC for invite link validation.
- **Deep linking**: Flutter deep link handling for invite URLs (e.g. `ventry://invite/{code}`)
- **All controllers**: Must respect `activeOrgId` context switches and reload data
