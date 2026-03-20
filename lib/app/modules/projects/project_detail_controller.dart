import 'package:get/get.dart';
import '../../data/models/project_model.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/item_repository.dart';
import '../../theme/app_colors.dart';

class ProjectDetailController extends GetxController {
  final _projectRepo = ProjectRepository();
  final _itemRepo = ItemRepository();

  final project = Rxn<ProjectModel>();
  final items = <ItemModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  late final String projectId;

  @override
  void onInit() {
    super.onInit();
    projectId = Get.parameters['id'] ?? '';
    if (projectId.isNotEmpty) loadProject();
  }

  Future<void> loadProject() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      project.value = await _projectRepo.getById(projectId);
      if (project.value != null) {
        items.value = await _itemRepo.getByProject(projectId);
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeProject() async {
    try {
      await _projectRepo.complete(projectId, 'complete');
      await loadProject();
      Get.snackbar('Success', 'Project completed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.t1,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete project',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
    }
  }

  Future<void> archiveProject() async {
    try {
      await _projectRepo.update(projectId, {'status': 'archived'});
      await loadProject();
      Get.snackbar('Success', 'Project archived',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.t1,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to archive project',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
    }
  }

  Future<void> deleteProject() async {
    try {
      await _projectRepo.delete(projectId);
      Get.back();
      Get.snackbar('Deleted', 'Project has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.t1,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete project',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
    }
  }
}
