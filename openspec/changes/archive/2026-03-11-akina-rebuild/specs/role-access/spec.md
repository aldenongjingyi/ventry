# Role-Based Access Control

## Overview

Each user has a role per organisation: admin or member. Roles control what actions a user can perform. Access is enforced in the client UI (hiding or disabling controls) and in Supabase RLS policies (preventing unauthorized writes at the database level).

## Requirements

### Role Definitions

1. **Admin** can:
   - Create, edit, and delete items.
   - Retire items (set status to `retired`).
   - Generate and print QR codes.
   - Create, edit, complete, and archive projects.
   - Invite, remove, and change roles of org members.
   - Relocate items (all relocation actions).
   - View all data (items, projects, activity log, members).

2. **Member** can:
   - View all items, projects, and activity log.
   - Scan QR codes and relocate items (Move to Storage, Assign to Project, Mark Missing, Mark Under Repair).
   - View their own profile and switch orgs.

3. **Member cannot**:
   - Create, edit, or delete items.
   - Retire items.
   - Create, edit, complete, or archive projects.
   - Invite, remove, or change roles of members.
   - Access admin sections of the account screen (Manage Items, Manage Projects, Members management).

### Enforcement

4. In the UI, controls for actions the user cannot perform are hidden (not shown as disabled).
5. All write operations are guarded by Supabase RLS policies that check the user's role in the active organisation via the `org_memberships` table.
6. If a member somehow triggers a restricted action (e.g., via deep link or API call), the RLS policy rejects the operation and the client displays a "Permission denied" error.
7. Role checks in the client use the cached membership record; the cache is refreshed on app launch, org switch, and pull-to-refresh.

### Role Management

8. Only admins can change another member's role.
9. An admin cannot demote themselves if they are the sole admin of the org (at least one admin must remain).
10. Role changes take effect immediately. The affected user's cached role is invalidated on their next data fetch or realtime event.

## Data Model

No new tables. Uses `org_memberships.role` (enum: admin, member).

## Behavior

- The role is evaluated per organisation. A user who is admin in Org A and member in Org B sees different UI capabilities when switching orgs.
- RLS policies use a helper function (e.g., `get_user_role_in_org(org_id)`) to avoid duplicating role-check logic across policies.
- If a user's membership is deleted while they are active in the app, the next data fetch returns empty results; the client detects this and redirects to onboarding or org selection.
