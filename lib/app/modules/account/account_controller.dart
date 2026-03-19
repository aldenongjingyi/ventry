import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

class AccountController extends GetxController {
  final _supabase = SupabaseService.to;

  String get userName => _supabase.currentUser?.userMetadata?['full_name'] ??
                          _supabase.currentUser?.email ?? 'User';
  String get userEmail => _supabase.currentUser?.email ?? '';
  String get orgName => _supabase.activeOrgName.value;
  bool get isAdmin => _supabase.isAdmin;

  final memberships = <Map<String, dynamic>>[].obs;
  final isSwitching = false.obs;
  final isLoadingMemberships = true.obs;
  final hasMembershipError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMemberships();
  }

  Future<void> loadMemberships() async {
    isLoadingMemberships.value = true;
    hasMembershipError.value = false;
    try {
      memberships.value = await _supabase.getAllMemberships();
    } catch (_) {
      hasMembershipError.value = true;
    } finally {
      isLoadingMemberships.value = false;
    }
  }

  bool get hasMultipleOrgs => memberships.length > 1;
  bool get canSwitchOrgs => hasMultipleOrgs || _supabase.isPro;

  Future<void> switchToOrg(Map<String, dynamic> membership) async {
    isSwitching.value = true;
    try {
      final orgId = membership['organisation_id'] as String;
      final role = membership['role'] as String;
      final orgData = membership['organisations'] as Map<String, dynamic>;
      final orgName = orgData['name'] as String;
      final plan = orgData['plan'] as String? ?? 'free';
      await _supabase.switchOrg(orgId, orgName, role, plan);
    } catch (e) {
      Get.snackbar('Error', 'Failed to switch organisation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
    } finally {
      isSwitching.value = false;
    }
  }

  Future<void> joinOrgWithCode(String code) async {
    try {
      final fullName = _supabase.currentUser?.userMetadata?['full_name'] ??
          _supabase.currentUser?.email ?? 'User';

      await _supabase.client.rpc('accept_invite', params: {
        'p_code': code,
        'p_full_name': fullName,
      });

      // Fetch the newly joined membership
      final membership = await _supabase.client
          .from('org_memberships')
          .select('organisation_id, role, organisations!inner(name, plan)')
          .eq('user_id', _supabase.userId!)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final orgId = membership['organisation_id'] as String;
      final role = membership['role'] as String;
      final orgData = membership['organisations'] as Map<String, dynamic>;
      final orgName = orgData['name'] as String;
      final plan = orgData['plan'] as String? ?? 'free';

      await _supabase.switchOrg(orgId, orgName, role, plan);
      await loadMemberships();

      Get.snackbar('Joined', 'You joined $orgName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      final msg = e is PostgrestException ? e.message : 'Failed to join organisation';
      Get.snackbar('Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
