import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/config/flavor_config.dart';
import 'app/data/services/supabase_service.dart';
import 'app/routes/app_routes.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: FlavorConfig.instance.envFile);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Pre-create SupabaseService so org context is ready before the widget tree builds
  final svc = Get.put(SupabaseService(), permanent: true);

  final user = Supabase.instance.client.auth.currentUser;
  String initialRoute = AppRoutes.login;
  if (user != null) {
    try {
      final memberships = await svc.getAllMemberships();

      if (memberships.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final hasOnboarded = prefs.getBool('hasCompletedOnboarding') ?? false;
        initialRoute = hasOnboarded ? AppRoutes.noOrganisation : AppRoutes.onboarding;
      } else {
        // Find saved org or fall back to first membership
        final prefs = await SharedPreferences.getInstance();
        final savedOrgId = prefs.getString('active_org_${user.id}');

        Map<String, dynamic>? target;
        if (savedOrgId != null) {
          target = memberships
              .where((m) => m['organisation_id'] == savedOrgId)
              .firstOrNull;
        }
        target ??= memberships.first;

        final orgId = target['organisation_id'] as String;
        final role = target['role'] as String;
        final orgData = target['organisations'] as Map<String, dynamic>;
        final orgName = orgData['name'] as String;
        final plan = orgData['plan'] as String? ?? 'free';
        await svc.setActiveOrg(orgId, orgName, role, plan);

        initialRoute = AppRoutes.shell;
      }
    } catch (_) {
      // Fall back to login
    }
  }

  runApp(VentryApp(initialRoute: initialRoute));
}
