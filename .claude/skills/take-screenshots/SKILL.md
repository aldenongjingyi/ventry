---
name: take-screenshots
description: Run the screenshot integration test and capture all app screens to a specified output directory.
user-invokable: true
---

# Take Screenshots

Runs the screenshot integration test to capture all app screens as PNG files.

**Input**: Optionally specify an output directory path. Defaults to `screenshots/` in the project root.

Examples:
- `/take-screenshots` → saves to `screenshots/`
- `/take-screenshots ~/Desktop/ventry-screens` → saves to `~/Desktop/ventry-screens`

## Steps

1. **Determine output directory**
   - Use the path provided by the user, or default to `screenshots/`
   - Create the directory if it doesn't exist

2. **Clean output directory**
   - If the output directory already exists, delete it first (`rm -rf`) and recreate it
   - This ensures stale screenshots from previous runs don't persist

3. **Check for a running device**
   - Run `flutter devices` to find a connected device
   - If no device is found, ask the user to start an emulator and try again

4. **Run the integration test**
   ```bash
   flutter drive \
     --driver=test_driver/integration_test.dart \
     --target=integration_test/screenshot_test.dart \
     --flavor dev \
     -d <DEVICE_ID>
   ```

5. **Move screenshots if custom output path**
   - If the user specified a path other than `screenshots/`, move all `.png` files from `screenshots/` to the target directory after the test completes

6. **Report results**
   - List all captured screenshots with their file paths
   - Report any failures

## Reference

The test captures these screens (see `.claude/skills/screenshot-setup/SKILL.md` for full details):

| # | File | Screen |
|---|------|--------|
| 01 | `01_home.png` | Home tab |
| 02 | `02_projects.png` | Projects tab |
| 03 | `03_items.png` | Items tab |
| 04 | `04_account.png` | Account tab |
| 05 | `05_home_scrolled.png` | Home scrolled |
| 06 | `06_members.png` | Members |
| 07 | `07_about.png` | About |
| 08 | `08_scanner_settings.png` | Scanner Settings |
| 09 | `09_upgrade.png` | Upgrade |
| 10 | `10_project_detail.png` | Project Detail |
| 11 | `11_item_detail.png` | Item Detail |
| 12 | `12_scan.png` | QR Scanner |
