import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/activity_log_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/project_model.dart';
import '../../data/providers/project_provider.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../theme/app_colors.dart';

class ProjectsController extends GetxController {
  final _projectRepo = ProjectRepository();
  final _projectProvider = ProjectProvider();
  final _itemRepo = ItemRepository();
  final _activityRepo = ActivityRepository();
  final projects = <ProjectModel>[].obs;
  final items = <ItemModel>[].obs;
  final recentActivity = <ActivityLogModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final filterStatus = ''.obs;

  RealtimeChannel? _channel;

  String get orgId => SupabaseService.to.activeOrgId.value ?? '';

  // Item stats
  int get totalItems => items.length;
  int get storageCount => items.where((i) => i.status == 'storage').length;
  int get inProjectCount => items.where((i) => i.status == 'in_project').length;
  int get missingCount => items.where((i) => i.status == 'missing').length;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    if (orgId.isEmpty) return;
    _channel = _projectProvider.subscribeToChanges(orgId, (_) => loadProjects());
  }

  Future<void> loadProjects() async {
    if (orgId.isEmpty) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _projectRepo.getByOrg(orgId),
        _itemRepo.getByOrg(orgId),
        _activityRepo.getByOrg(orgId, limit: 3),
      ]);
      projects.value = results[0] as List<ProjectModel>;
      items.value = results[1] as List<ItemModel>;
      recentActivity.value = results[2] as List<ActivityLogModel>;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createProject(
    String name, {
    String? location,
    String? icon,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    List<String> assignItemIds = const [],
  }) async {
    if (projects.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar('Error', 'A project with that name already exists',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
      return false;
    }
    try {
      final project = await _projectRepo.create(
        orgId,
        name,
        location: location,
        icon: icon,
        description: description,
        startDate: startDate,
        dueDate: dueDate,
      );
      // Assign items to the new project
      for (final itemId in assignItemIds) {
        await _itemRepo.relocate(itemId, 'in_project', projectId: project.id);
      }
      await loadProjects();
      SupabaseService.to.loadOrgUsage();
      Get.snackbar('Success', 'Project created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.t1,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create project',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
      return false;
    }
  }

  List<ProjectModel> get activeProjects => projects.where((p) => p.status == 'active').toList();
  List<ProjectModel> get completedProjects => projects.where((p) => p.status == 'completed').toList();
  List<ProjectModel> get archivedProjects => projects.where((p) => p.status == 'archived').toList();

  List<ProjectModel> get filteredProjects {
    if (filterStatus.value.isEmpty) return projects;
    return projects.where((p) => p.status == filterStatus.value).toList();
  }

  void setFilterStatus(String status) => filterStatus.value = status;

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }
}
