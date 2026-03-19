## ADDED Requirements

### Requirement: Admin can generate shareable invite links
The system SHALL allow org admins to generate invite links in addition to invite codes. The invite link SHALL encode the invite code in a URL format: `https://ventry.app/invite/{code}`.

#### Scenario: Generate invite link
- **WHEN** admin taps "Copy Link" after generating an invite code
- **THEN** system copies `https://ventry.app/invite/{code}` to the clipboard
- **THEN** system displays a confirmation snackbar

#### Scenario: Generate invite link alongside code display
- **WHEN** admin generates an invite code via the existing invite sheet
- **THEN** system displays both the code and a "Copy Link" button
- **THEN** the link and code refer to the same invite record

### Requirement: App handles incoming invite deep links
The system SHALL handle deep links matching the pattern `https://ventry.app/invite/{code}`. When a deep link is received, the system SHALL extract the code and initiate the join flow.

#### Scenario: Deep link received while authenticated
- **WHEN** authenticated user opens an invite link `https://ventry.app/invite/A1B2C3D4`
- **THEN** system extracts code `A1B2C3D4`
- **THEN** system shows a confirmation bottom sheet with the org name (looked up via code)
- **THEN** on user confirmation, system calls `accept_invite` RPC

#### Scenario: Deep link received while not authenticated
- **WHEN** unauthenticated user opens an invite link
- **THEN** system stores the invite code as a pending invite
- **THEN** system navigates to login screen
- **WHEN** user completes authentication
- **THEN** system automatically processes the stored invite code

#### Scenario: Deep link with invalid code
- **WHEN** user opens an invite link with an invalid or expired code
- **THEN** system displays an error: "This invite link is invalid or has expired"

### Requirement: Invite link uses universal link format
The system SHALL use HTTPS universal links (`https://ventry.app/invite/{code}`) rather than custom URI schemes to ensure links work across all platforms and messaging apps.

#### Scenario: Link shared via messaging app
- **WHEN** a user shares the invite link via WhatsApp, iMessage, or any messaging app
- **THEN** the recipient can tap the link and it opens the Ventry app (if installed) or the app store
