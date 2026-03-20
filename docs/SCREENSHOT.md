# Screenshot Capture

Automated screenshots of the app using Flutter integration tests. Useful for sharing with clients without exporting an APK/IPA.

## Prerequisites

- An Android emulator or physical device connected

Check available devices:

```bash
flutter devices
```

## Run

### With Claude Code

```
/take-screenshots
/take-screenshots ~/Desktop/ventry-screens
```

### Manual

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  --flavor dev \
  -d <DEVICE_ID>
```

Replace `<DEVICE_ID>` with your device (e.g. `emulator-5554`).

## Output

Screenshots are saved to `screenshots/` in the project root:

| File | Screen | Navigation |
|------|--------|------------|
| `01_home.png` | Home tab | Initial load |
| `02_projects.png` | Projects tab | Bottom nav |
| `03_items.png` | Items tab | Bottom nav |
| `04_account.png` | Account tab | Bottom nav |
| `05_home_scrolled.png` | Home tab scrolled | Drag -400px |
| `06_members.png` | Members | Programmatic nav |
| `07_about.png` | About | Programmatic nav |
| `08_scanner_settings.png` | Scanner Settings | Programmatic nav |
| `09_upgrade.png` | Upgrade | Programmatic nav |
| `10_project_detail.png` | Project Detail | Projects → first project |
| `11_item_detail.png` | Item Detail | Items → first item |
| `12_scan.png` | QR Scanner | Programmatic nav |

## Adding More Screenshots

Edit `integration_test/screenshot_test.dart`. The pattern for sub-screens:

```dart
// Navigate to the screen
Get.toNamed(AppRoutes.routeName);
await _waitFor(tester, find.text('Expected text on screen'));
await _settle(tester);
await binding.takeScreenshot('NN_screen_name');
Get.back();
await _settle(tester);
```

For screens reachable by tapping:

```dart
await tester.tap(find.text('Button Label'));
await _waitFor(tester, find.text('Expected text'));
await _settle(tester);
await binding.takeScreenshot('NN_screen_name');
Get.back();
await _settle(tester);
```

See `.claude/skills/screenshot-setup/SKILL.md` for the full skill reference.

## Notes

- The test uses the **dev flavor** with real Supabase data — requires network connection.
- `pumpAndSettle` is intentionally avoided because timers and animations may prevent it from ever settling. Fixed-duration `pump()` calls are used instead.
- The `convertFlutterSurfaceToImage()` call is required for Android and must only be called once.
