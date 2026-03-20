import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ventry/app/routes/app_routes.dart';
import 'package:ventry/main_dev.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture app screenshots', (tester) async {
    // Boot the real app (dev flavor)
    app.main();

    // Wait for splash/auth to resolve
    await _settle(tester);
    await _settle(tester);
    await _settle(tester);

    // If login screen is showing, sign in with dev account
    final signInBtn = find.text('Sign In');
    if (signInBtn.evaluate().isNotEmpty) {
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'aldenongjingyi@gmail.com');
      await _settle(tester);

      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, '1212100640');
      await _settle(tester);

      await tester.tap(find.text('Sign In'));
      await _settle(tester);
      await _settle(tester);
      await _settle(tester);
      await _settle(tester);
    }

    // Wait for shell to load (Home tab)
    await _waitFor(tester, find.text('Home'), timeout: 30);
    await _settle(tester);
    await _settle(tester);

    // Convert Flutter surface to image once (Android requirement)
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();

    // ── 01. Home tab ─────────────────────────────────────────────────────────
    await binding.takeScreenshot('01_home');

    // ── 02. Projects tab ─────────────────────────────────────────────────────
    await tester.tap(find.text('Projects'));
    await _settle(tester);
    await binding.takeScreenshot('02_projects');

    // ── 03. Items tab ────────────────────────────────────────────────────────
    await tester.tap(find.text('Items'));
    await _settle(tester);
    await binding.takeScreenshot('03_items');

    // ── 04. Account tab ──────────────────────────────────────────────────────
    await tester.tap(find.text('Account'));
    await _settle(tester);
    await binding.takeScreenshot('04_account');

    // ── 05. Home scrolled ────────────────────────────────────────────────────
    await tester.tap(find.text('Home'));
    await _settle(tester);
    final scrollables = find.byType(ListView);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, -400));
      await _settle(tester);
    }
    await binding.takeScreenshot('05_home_scrolled');

    // Scroll back up
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, 400));
      await _settle(tester);
    }

    // ── 06. Members ──────────────────────────────────────────────────────────
    Get.toNamed(AppRoutes.members);
    await _waitFor(tester, find.text('Members'));
    await _settle(tester);
    await binding.takeScreenshot('06_members');
    Get.back();
    await _settle(tester);

    // ── 07. About ────────────────────────────────────────────────────────────
    Get.toNamed(AppRoutes.about);
    await _waitFor(tester, find.text('About'));
    await _settle(tester);
    await binding.takeScreenshot('07_about');
    Get.back();
    await _settle(tester);

    // ── 08. Scanner Settings ─────────────────────────────────────────────────
    Get.toNamed(AppRoutes.scannerSettings);
    await _waitFor(tester, find.text('Scanner Settings'));
    await _settle(tester);
    await binding.takeScreenshot('08_scanner_settings');
    Get.back();
    await _settle(tester);

    // ── 09. Upgrade ──────────────────────────────────────────────────────────
    Get.toNamed(AppRoutes.upgrade);
    await _waitFor(tester, find.text('Upgrade'));
    await _settle(tester);
    await binding.takeScreenshot('09_upgrade');
    Get.back();
    await _settle(tester);

    // ── 10. Project Detail ───────────────────────────────────────────────────
    // Navigate to Projects tab and tap first project if available
    await tester.tap(find.text('Projects'));
    await _settle(tester);
    final projectCards = find.byType(InkWell);
    if (projectCards.evaluate().length > 1) {
      await tester.tap(projectCards.first);
      await _settle(tester);
      await _settle(tester);
      await binding.takeScreenshot('10_project_detail');
      Get.back();
      await _settle(tester);
    }

    // ── 11. Item Detail ──────────────────────────────────────────────────────
    await tester.tap(find.text('Items'));
    await _settle(tester);
    final itemCards = find.byType(InkWell);
    if (itemCards.evaluate().length > 1) {
      await tester.tap(itemCards.first);
      await _settle(tester);
      await _settle(tester);
      await binding.takeScreenshot('11_item_detail');
      Get.back();
      await _settle(tester);
    }

    // ── 12. Scan ─────────────────────────────────────────────────────────────
    Get.toNamed(AppRoutes.scan);
    await _settle(tester);
    await _settle(tester);
    await binding.takeScreenshot('12_scan');
    Get.back();
    await _settle(tester);
  });
}

/// Pump frames until [finder] matches at least one widget, or fail after [timeout] seconds.
Future<void> _waitFor(WidgetTester tester, Finder finder, {int timeout = 10}) async {
  for (int i = 0; i < timeout * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  await _settle(tester);
  expect(finder, findsWidgets);
}

/// Pump a fixed number of frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
