---
name: screenshot-setup
description: Auto-detect all app screens, update the screenshot test and docs, then capture screenshots.
user-invokable: true
autoContext: |
  updating screenshot tests
  adding new screens to screenshot coverage
  modifying integration_test/screenshot_test.dart
---

# Screenshot Setup

Automatically discovers all screens in the app, updates the integration test to cover them, updates documentation, and runs the test to capture PNGs.

**Input**: None required. Optionally specify an output directory (default: `screenshots/`).

## Steps

### 1. Discover all screens

Read these files to build a complete list of screens:

- `lib/app/routes/app_routes.dart` — all route constants
- `lib/app/routes/app_pages.dart` — all registered GetPage entries
- View files for each module (`lib/app/modules/*/views/*.dart` and `lib/app/modules/*/*.dart`) — to find:
  - AppBar titles (the `_waitFor` text target)
  - Dialogs/bottom sheets launched from views
  - Sub-screens reachable by tapping list items

Skip auth routes (login, signup, verifyOtp, onboarding, noOrganisation, joinInvite) — they aren't accessible in the logged-in test session.

### 2. Diff against current coverage

Read `integration_test/screenshot_test.dart` and extract all `takeScreenshot('...')` calls.

Compare against the discovered screens. Identify:
- **New screens** not yet in the test
- **Removed screens** that no longer exist (routes deleted, views removed)

If nothing changed, skip to step 5 (just run the test).

### 3. Update the test

For each new screen, add a test block following these patterns:

**Programmatic navigation** (preferred for standalone pages):
```dart
// ── NN. Screen Name ──────────────────────────────────────────────
Get.toNamed(AppRoutes.routeName);
await _waitFor(tester, find.text('AppBar Title'));
await _settle(tester);
await binding.takeScreenshot('NN_screen_name');
Get.back();
await _settle(tester);
```

**Tab navigation** (for bottom nav tabs):
```dart
// ── NN. Tab Name ─────────────────────────────────────────────────
await tester.tap(find.text('Tab Label'));
await _settle(tester);
await binding.takeScreenshot('NN_tab_name');
```

**List item detail** (for detail screens reached by tapping a list item):
```dart
// ── NN. Detail Screen ────────────────────────────────────────────
await tester.tap(find.text('Tab With List'));
await _settle(tester);
final cards = find.byType(InkWell);
if (cards.evaluate().length > 1) {
  await tester.tap(cards.first);
  await _settle(tester);
  await _settle(tester);
  await binding.takeScreenshot('NN_detail_name');
  Get.back();
  await _settle(tester);
}
```

**Key rules:**
- Number screenshots sequentially (NN = next available number)
- Always `Get.back()` + `_settle()` after each capture
- Use `_waitFor` with the AppBar title text from the view file
- Never use `pumpAndSettle` — always use `_settle(tester)`
- For bottom tabs, tap the tab label text: `await tester.tap(find.text('Tab Name'));`
- Use `.last` on finders if the text might exist on multiple pages in the widget tree
- The dev account credentials are: `aldenongjingyi@gmail.com` / `1212100640`

Remove test blocks for any deleted screens and renumber if needed.

### 4. Update documentation

Update these three files to match the new coverage:

1. **`docs/SCREENSHOT.md`** — update the screenshot table
2. **`.claude/skills/screenshot-setup/SKILL.md`** — update the coverage table below
3. **`.claude/skills/take-screenshots/SKILL.md`** — update the reference table

### 5. Run the test

Execute `/take-screenshots` to capture all PNGs.

### 6. Report

List any screens that were added or removed, and confirm all PNGs were captured.

---

## Current Coverage (12 screenshots)

| # | File | Screen | Navigation |
|---|------|--------|------------|
| 01 | `01_home.png` | Home tab | Already loaded |
| 02 | `02_projects.png` | Projects tab | Tap 'Projects' tab |
| 03 | `03_items.png` | Items tab | Tap 'Items' tab |
| 04 | `04_account.png` | Account tab | Tap 'Account' tab |
| 05 | `05_home_scrolled.png` | Home scrolled | Tap 'Home', drag -400px |
| 06 | `06_members.png` | Members | `Get.toNamed(AppRoutes.members)` |
| 07 | `07_about.png` | About | `Get.toNamed(AppRoutes.about)` |
| 08 | `08_scanner_settings.png` | Scanner Settings | `Get.toNamed(AppRoutes.scannerSettings)` |
| 09 | `09_upgrade.png` | Upgrade | `Get.toNamed(AppRoutes.upgrade)` |
| 10 | `10_project_detail.png` | Project Detail | Projects → first project |
| 11 | `11_item_detail.png` | Item Detail | Items → first item |
| 12 | `12_scan.png` | QR Scanner | `Get.toNamed(AppRoutes.scan)` |

## Navigation Strategies

- **Bottom tabs**: `await tester.tap(find.text('Tab Name'));` — Home, Projects, Items, Account.
- **List items**: Tap by finding InkWell widgets and tapping the first one.
- **Programmatic**: `Get.toNamed(AppRoutes.routeName);` — preferred when no easy tap target exists.

## Constraints

- **No `pumpAndSettle`**: Timers and animations may prevent `pumpAndSettle` from ever completing. Always use `_settle(tester)` (pumps 20 frames × 100ms).
- **`convertFlutterSurfaceToImage()`**: Must be called exactly once before the first screenshot. Required for Android.
- **Return to parent**: Always `Get.back()` + `_settle()` after capturing a sub-screen, so the next navigation starts from a known state.
- **Network dependency**: Unlike keppel_flutter, Ventry dev flavor uses real Supabase — an internet connection is required.
