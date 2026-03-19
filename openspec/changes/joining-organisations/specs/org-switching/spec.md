## ADDED Requirements

### Requirement: User can switch active organisation
The system SHALL allow a user who belongs to multiple organisations to switch the active organisation context. On switch, all data (items, projects, activity, members) SHALL reload to reflect the newly selected org.

#### Scenario: Switch org from Account screen
- **WHEN** user taps "Switch Organisation" in the Account screen
- **THEN** system displays a list of all organisations the user belongs to, with the current org highlighted
- **WHEN** user selects a different org
- **THEN** system updates the active org context, persists the selection, and reloads all shell data

#### Scenario: Org switch shows loading state
- **WHEN** user selects a different org to switch to
- **THEN** system displays a loading indicator while data reloads
- **THEN** system clears previous org's data from all controllers before loading new data

### Requirement: User can join additional organisations from Account
The system SHALL provide a "Join Organisation" option in the Account screen that allows the user to join another org via invite code. This flow SHALL be identical to the onboarding join flow.

#### Scenario: Join via invite code from Account
- **WHEN** user taps "Join Organisation" in Account and enters a valid invite code
- **THEN** system calls `accept_invite` RPC with the code and user's full name
- **THEN** system adds the new org to the user's membership list and switches to it

#### Scenario: Join blocked by plan (multi-org gate)
- **WHEN** user already belongs to one org on the Free or Starter plan and attempts to join another
- **THEN** system displays an upgrade prompt explaining multi-org requires Pro plan
- **THEN** system does NOT call the `accept_invite` RPC

#### Scenario: Join when already a member
- **WHEN** user enters an invite code for an org they already belong to
- **THEN** system displays an error: "You are already a member of this organisation"

### Requirement: Org picker on login with multiple memberships
The system SHALL show an org picker when a user with multiple memberships logs in, unless a previously-used org is stored. If a stored org exists and the user is still a member, the system SHALL auto-select it.

#### Scenario: Login with multiple orgs and no stored preference
- **WHEN** user logs in and has memberships in 2+ orgs and no stored last-used org
- **THEN** system displays an org picker bottom sheet listing all orgs with name and role
- **WHEN** user selects an org
- **THEN** system sets it as active, persists it, and navigates to shell

#### Scenario: Login with stored org preference
- **WHEN** user logs in and has a stored last-used org that they are still a member of
- **THEN** system auto-selects that org and navigates to shell without showing the picker

#### Scenario: Login with stored org but membership removed
- **WHEN** user logs in and the stored org is no longer in their memberships
- **THEN** system clears the stored preference and shows the org picker

### Requirement: Persist active org selection per user
The system SHALL store the active org selection keyed by user ID so that multiple users on the same device do not conflict.

#### Scenario: Different users on same device
- **WHEN** user A logs out and user B logs in on the same device
- **THEN** user B's stored org preference is independent of user A's
