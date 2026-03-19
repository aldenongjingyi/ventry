# Account Screen

## Overview

The account screen is the user's hub for profile management, organisation switching, team management, and app settings. Sections are shown or hidden based on the user's role in the active organisation.

## Requirements

### User Profile

1. Displays the user's name and email address at the top of the screen.
2. The user can edit their display name. Email is read-only (managed via Supabase Auth).
3. Profile photo is not supported in v1.

### Organisation Switcher

4. If the user belongs to multiple organisations, an org switcher section is shown below the profile.
5. The current org is highlighted. Tapping another org switches the active org and reloads all app data.
6. If the user belongs to only one org, this section is hidden.

### Members Section (Admin Only)

7. Visible only to admins of the active org.
8. Lists all members of the org with their name, email, and role.
9. Admins can change a member's role (admin/member) via a dropdown or tap action.
10. Admins can remove a member with a confirmation dialog.
11. Admins can invite a new member by entering an email address and selecting a role.
12. The sole admin cannot demote or remove themselves.

### Manage Items (Admin Only)

13. Visible only to admins.
14. A shortcut entry that navigates to the item list in management mode (with add/edit/retire controls visible).

### Manage Projects (Admin Only)

15. Visible only to admins.
16. A shortcut entry that navigates to the project list in management mode (with create/archive controls visible).

### App Settings

17. **Scanner mode**: selector for Quick, Smart, or Manual mode (see scanner-modes spec).
18. **Default scanner input**: toggle between Camera and HID as the default scanner input.
19. **Quick Mode default action**: picker for the action applied automatically in Quick Mode.
20. **Notifications**: toggle for push notification preferences (placeholder for v1; no backend implementation required).
21. **Theme**: toggle between light, dark, and system default.

### Logout

22. A logout button at the bottom of the screen.
23. Tapping logout shows a confirmation dialog, then signs the user out via Supabase Auth and navigates to the login screen.
24. Local state (active org, preferences) is cleared on logout.

## Data Model

No new tables. Reads from auth.users, org_memberships, and organisations. Preferences are stored in local storage (SharedPreferences / Hive).

## Behavior

- The account screen is accessible from the app shell's bottom navigation or side menu.
- Admin-only sections are hidden entirely for members, not shown as disabled.
- Changes to scanner mode and theme take effect immediately without restarting the app.
- If the user removes a member who is currently active in the app, that member's next data fetch will detect the missing membership and redirect them appropriately (see org-management spec).
- The members list updates in real time if another admin adds or removes a member concurrently.
