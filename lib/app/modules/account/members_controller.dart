import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/org_membership_model.dart';
import '../../data/providers/member_provider.dart';
import '../../data/repositories/member_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../theme/app_colors.dart';

class MembersController extends GetxController {
  final _repo = MemberRepository();
  final _provider = MemberProvider();
  final members = <OrgMembershipModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  RealtimeChannel? _channel;

  String get orgId => SupabaseService.to.activeOrgId.value ?? '';

  @override
  void onInit() {
    super.onInit();
    loadMembers();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    if (orgId.isEmpty) return;
    _channel = _provider.subscribeToChanges(orgId, (_) => loadMembers());
  }

  Future<void> loadMembers() async {
    if (orgId.isEmpty) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      members.value = await _repo.getByOrg(orgId);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleRole(OrgMembershipModel member) async {
    final newRole = member.isAdmin ? 'member' : 'admin';
    try {
      await _repo.updateRole(member.id, newRole);
      await loadMembers();
      Get.snackbar('Success', 'Role updated to $newRole',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
    }
  }

  Future<void> removeMember(OrgMembershipModel member) async {
    try {
      await _repo.remove(member.id);
      await loadMembers();
      Get.snackbar('Removed', '${member.fullName} has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove member',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
    }
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }
}
