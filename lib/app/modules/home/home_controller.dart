import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/activity_log_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/services/supabase_service.dart';

class HomeController extends GetxController {
  final _itemRepo = ItemRepository();
  final _projectRepo = ProjectRepository();
  final _activityRepo = ActivityRepository();

  final items = <ItemModel>[].obs;
  final projects = <ProjectModel>[].obs;
  final recentActivity = <ActivityLogModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  // Checklist
  final checklistProject = false.obs;
  final checklistItem = false.obs;
  final checklistInvite = false.obs;

  String get orgId => SupabaseService.to.activeOrgId.value ?? '';

  // Stats
  int get totalItems => items.length;
  int get inStorageCount => items.where((i) => i.status == 'in_storage').length;
  int get inProjectCount => items.where((i) => i.status == 'in_project').length;
  int get missingCount => items.where((i) => i.status == 'missing').length;
  int get activeProjectCount =>
      projects.where((p) => p.status == 'active').length;

  /// Check-in percentage for a project (items with status 'in_project' / total items assigned).
  double projectCheckInPercent(String projectId) {
    final projectItems = items.where((i) => i.projectId == projectId).toList();
    if (projectItems.isEmpty) return 0;
    final checkedIn = projectItems.where((i) => i.status == 'in_project').length;
    return checkedIn / projectItems.length;
  }

  List<ProjectModel> get activeProjects =>
      projects.where((p) => p.status == 'active').take(3).toList();

  bool get hasContent =>
      items.isNotEmpty || projects.isNotEmpty || recentActivity.isNotEmpty;

  bool get allChecklistDone =>
      checklistProject.value && checklistItem.value && checklistInvite.value;

  // Greeting
  String get firstName {
    final fullName =
        SupabaseService.to.currentUser?.userMetadata?['full_name'] as String?;
    if (fullName == null || fullName.isEmpty) return '';
    return fullName.split(' ').first;
  }

  String get greeting {
    final hour = DateTime.now().hour;
    final prefix =
        hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final name = firstName;
    return name.isEmpty ? prefix : '$prefix, $name';
  }

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    if (orgId.isEmpty) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _itemRepo.getByOrg(orgId),
        _projectRepo.getByOrg(orgId),
        _activityRepo.getByOrg(orgId, limit: 5),
      ]);
      items.value = results[0] as List<ItemModel>;
      projects.value = results[1] as List<ProjectModel>;
      recentActivity.value = results[2] as List<ActivityLogModel>;
      await _loadChecklist();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    checklistProject.value =
        prefs.getBool('checklist_project_$orgId') ?? projects.isNotEmpty;
    checklistItem.value =
        prefs.getBool('checklist_item_$orgId') ?? items.isNotEmpty;
    checklistInvite.value =
        prefs.getBool('checklist_invite_$orgId') ?? false;

    // Auto-complete checklist steps based on data
    if (projects.isNotEmpty && !checklistProject.value) {
      checklistProject.value = true;
      prefs.setBool('checklist_project_$orgId', true);
    }
    if (items.isNotEmpty && !checklistItem.value) {
      checklistItem.value = true;
      prefs.setBool('checklist_item_$orgId', true);
    }
  }

  Future<void> completeChecklist(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('checklist_${key}_$orgId', true);
    switch (key) {
      case 'project':
        checklistProject.value = true;
      case 'item':
        checklistItem.value = true;
      case 'invite':
        checklistInvite.value = true;
    }
  }
}
