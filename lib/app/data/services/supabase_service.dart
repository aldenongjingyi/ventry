import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/flavor_config.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => client.auth;
  User? get currentUser => auth.currentUser;
  String? get userId => currentUser?.id;

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get onAuthStateChange => auth.onAuthStateChange;

  // Active organisation context
  final activeOrgId = Rxn<String>();
  final activeOrgName = ''.obs;
  final userRole = ''.obs;
  final activePlan = 'free'.obs;

  // Plan usage (populated by loadOrgUsage)
  final orgUsage = Rxn<Map<String, dynamic>>();

  // Pending invite code from deep link (processed after auth)
  final pendingInviteCode = Rxn<String>();

  // Callback for reloading shell data after org switch
  VoidCallback? onOrgSwitched;

  // Per-user key for storing active org
  String get _activeOrgKey => 'active_org_${userId ?? 'unknown'}';

  @override
  void onInit() {
    super.onInit();
    _loadActiveOrg();
  }

  Future<void> _loadActiveOrg() async {
    // Skip if bootstrap already set the full org context
    if (userId == null || activeOrgId.value != null) return;
    final prefs = await SharedPreferences.getInstance();
    final savedOrgId = prefs.getString(_activeOrgKey);
    if (savedOrgId != null) {
      activeOrgId.value = savedOrgId;
    }
  }

  Future<void> setActiveOrg(String orgId, String orgName, String role, [String plan = 'free']) async {
    activeOrgId.value = orgId;
    activeOrgName.value = orgName;
    userRole.value = role;
    activePlan.value = FlavorConfig.isDev ? 'pro' : plan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeOrgKey, orgId);
  }

  bool get isAdmin => userRole.value == 'admin';
  bool get isFree => activePlan.value == 'free';
  bool get isPro => activePlan.value == 'pro';

  /// Fetch all memberships for the current user (with org details)
  Future<List<Map<String, dynamic>>> getAllMemberships() async {
    if (userId == null) return [];
    return await client
        .from('org_memberships')
        .select('organisation_id, role, organisations!inner(name, plan)')
        .eq('user_id', userId!)
        .order('created_at');
  }

  /// Switch active org, persist, reload usage, and notify shell
  Future<void> switchOrg(String orgId, String orgName, String role, String plan) async {
    await setActiveOrg(orgId, orgName, role, plan);
    await loadOrgUsage();
    onOrgSwitched?.call();
  }

  /// Fetch plan usage from server
  Future<void> loadOrgUsage() async {
    final orgId = activeOrgId.value;
    if (orgId == null) return;
    try {
      final result = await client.rpc('get_org_usage', params: {'p_org_id': orgId});
      orgUsage.value = Map<String, dynamic>.from(result as Map);
    } catch (_) {
      orgUsage.value = null;
    }
  }

  /// Check if a plan feature is enabled
  bool isFeatureEnabled(String feature) {
    final features = orgUsage.value?['features'] as Map<String, dynamic>?;
    return features?[feature] == true;
  }

  /// Check if multi-org feature is available on current plan
  bool get canJoinMultipleOrgs => isFeatureEnabled('multi_org');

  /// Check if activity log viewing is available on current plan
  bool get canViewActivityLog => isFeatureEnabled('activity_log_visible');

  /// Get usage for a specific resource (members, items, projects)
  Map<String, dynamic>? getResourceUsage(String resource) {
    return orgUsage.value?[resource] as Map<String, dynamic>?;
  }

  /// Check if a resource limit has been reached
  bool isLimitReached(String resource) {
    final usage = getResourceUsage(resource);
    if (usage == null) return false;
    final limit = usage['limit'];
    if (limit == null) return false; // unlimited
    return (usage['current'] as int? ?? 0) >= (limit as int);
  }

  /// Check if usage is at or above the warning threshold (80%)
  bool isNearLimit(String resource) {
    final usage = getResourceUsage(resource);
    if (usage == null) return false;
    final limit = usage['limit'];
    if (limit == null) return false;
    final current = usage['current'] as int? ?? 0;
    return current >= (limit as int) * 0.8;
  }

  Future<void> clearActiveOrg() async {
    activeOrgId.value = null;
    activeOrgName.value = '';
    userRole.value = '';
    activePlan.value = 'free';
    orgUsage.value = null;
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeOrgKey);
    }
  }

  Future<void> clearSession() async {
    await clearActiveOrg();
    pendingInviteCode.value = null;
    await auth.signOut();
  }
}
