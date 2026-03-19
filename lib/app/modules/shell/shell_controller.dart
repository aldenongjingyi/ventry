import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../data/services/supabase_service.dart';
import '../../routes/app_routes.dart';
import '../account/account_controller.dart';
import '../account/members_controller.dart';
import '../items/items_controller.dart';
import '../projects/projects_controller.dart';

class ShellController extends GetxController {
  final currentIndex = 1.obs; // Default to Projects tab

  @override
  void onInit() {
    super.onInit();
    if (SupabaseService.to.activeOrgId.value == null ||
        SupabaseService.to.activeOrgId.value!.isEmpty) {
      // Defer navigation to avoid calling Get.offAllNamed during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
      return;
    }
    SupabaseService.to.onOrgSwitched = _reloadAll;
    SupabaseService.to.loadOrgUsage();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void _reloadAll() {
    try { Get.find<ItemsController>().loadItems(); } catch (_) {}
    try { Get.find<ProjectsController>().loadProjects(); } catch (_) {}
    try { Get.find<MembersController>().loadMembers(); } catch (_) {}
    try { Get.find<AccountController>().loadMemberships(); } catch (_) {}
  }

  @override
  void onClose() {
    SupabaseService.to.onOrgSwitched = null;
    super.onClose();
  }
}
