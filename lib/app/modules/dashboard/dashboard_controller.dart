import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/providers/equipment_provider.dart';
import '../../data/providers/activity_provider.dart';

class DashboardController extends GetxController {
  final _equipmentRepo = EquipmentRepository();
  final _projectRepo = ProjectRepository();
  final _activityRepo = ActivityRepository();
  final _equipmentProvider = EquipmentProvider();
  final _activityProvider = ActivityProvider();

  final equipment = <EquipmentModel>[].obs;
  final activeProjects = <ProjectModel>[].obs;
  final recentActivity = <ActivityModel>[].obs;
  final isLoading = true.obs;

  RealtimeChannel? _equipmentChannel;
  RealtimeChannel? _activityChannel;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _subscribeToChanges();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _equipmentRepo.getAll(),
        _projectRepo.getByStatus('active'),
        _activityRepo.getRecent(limit: 10),
      ]);
      equipment.assignAll(results[0] as List<EquipmentModel>);
      activeProjects.assignAll(results[1] as List<ProjectModel>);
      recentActivity.assignAll(results[2] as List<ActivityModel>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToChanges() {
    _equipmentChannel = _equipmentProvider.subscribeToChanges((_) {
      _refreshEquipment();
    });
    _activityChannel = _activityProvider.subscribeToChanges((_) {
      _refreshActivity();
    });
  }

  Future<void> _refreshEquipment() async {
    try {
      final data = await _equipmentRepo.getAll();
      equipment.assignAll(data);
    } catch (_) {}
  }

  Future<void> _refreshActivity() async {
    try {
      final data = await _activityRepo.getRecent(limit: 10);
      recentActivity.assignAll(data);
    } catch (_) {}
  }

  // Stats
  int get totalCount => equipment.length;
  int get inStorageCount => equipment.where((e) => e.status == 'in-storage').length;
  int get checkedOutCount => equipment.where((e) => e.status == 'checked-out').length;
  int get maintenanceCount => equipment.where((e) => e.status == 'maintenance').length;

  @override
  void onClose() {
    _equipmentChannel?.unsubscribe();
    _activityChannel?.unsubscribe();
    super.onClose();
  }
}
