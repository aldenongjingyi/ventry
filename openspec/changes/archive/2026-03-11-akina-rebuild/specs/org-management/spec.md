# Org Management

## Overview

Users belong to one or more organisations. Every data query in the app is scoped to the currently active organisation. New users create their first org during onboarding. Users with multiple memberships can switch between orgs at any time.

## Requirements

1. A user may belong to one or more organisations.
2. Each membership carries a role: `admin` or `member`.
3. The app maintains an "active org" context that scopes all data queries and writes.
4. An org switcher is accessible from the account screen and the app shell header.
5. Switching orgs replaces all visible data with the newly selected org's data immediately.
6. During onboarding (first login, no memberships), the user must create an organisation, which also creates their membership with the `admin` role.
7. Admins can invite users to their org by email. The invitee receives an invite record they accept or decline on next login.
8. Admins can remove members from the org (but cannot remove themselves if they are the sole admin).
9. Org names must be non-empty and unique is not enforced (multiple orgs may share a name).
10. Deleting an org is not supported in v1; orgs can only be archived by the sole remaining admin.

## Data Model

- **organisations**: `id` (UUID PK), `name` (text), `created_at` (timestamptz).
- **org_memberships**: `id` (UUID PK), `user_id` (UUID FK -> auth.users), `organisation_id` (UUID FK -> organisations), `role` (enum: admin, member), `created_at` (timestamptz). Unique constraint on (user_id, organisation_id).
- **org_invites**: `id` (UUID PK), `organisation_id` (UUID FK), `invited_email` (text), `role` (enum), `invited_by` (UUID FK), `status` (enum: pending, accepted, declined), `created_at` (timestamptz).

## Behavior

- On app launch, if the user has no memberships, redirect to onboarding.
- On app launch, if the user has exactly one membership, auto-select that org.
- On app launch, if the user has multiple memberships, restore the last-used org from local storage; if none stored, prompt the user to choose.
- All Supabase RLS policies filter rows by the active org via a `get_active_organisation_id()` helper or equivalent client-side filtering.
- If a user's only membership is removed (e.g., admin removes them), they are redirected to onboarding on next data fetch.
- Org switcher shows org name and the user's role in each org.
