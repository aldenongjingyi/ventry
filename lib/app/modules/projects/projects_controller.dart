import 'package:get/get.dart';
import '../../data/models/project_model.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/assignment_repository.dart';

class ProjectsController extends GetxController {
  final _projectRepo = ProjectRepository();
  final _assignmentRepo = AssignmentRepository();

  final projects = <ProjectModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final projectAssignments = <AssignmentModel>[].obs;
  final isLoading = true.obs;
  final isDetailLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      final data = await _projectRepo.getAll();
      projects.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load projects',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProjectDetail(String id) async {
    try {
      isDetailLoading.value = true;
      final project = await _projectRepo.getById(id);
      selectedProject.value = project;

      if (project != null) {
        final assignments = await _assignmentRepo.getActiveByProject(id);
        projectAssignments.assignAll(assignments);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load project details',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetailLoading.value = false;
    }
  }

  List<ProjectModel> get activeProjects =>
      projects.where((p) => p.status == 'active').toList();

  List<ProjectModel> get completedProjects =>
      projects.where((p) => p.status == 'completed').toList();

  List<ProjectModel> get planningProjects =>
      projects.where((p) => p.status == 'planning').toList();
}
