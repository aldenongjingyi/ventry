import 'package:get/get.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/profile_repository.dart';

class CheckoutController extends GetxController {
  final _equipmentRepo = EquipmentRepository();
  final _assignmentRepo = AssignmentRepository();
  final _projectRepo = ProjectRepository();
  final _profileRepo = ProfileRepository();

  // Wizard state
  final currentStep = 0.obs;

  // Step 1: Select items
  final availableEquipment = <EquipmentModel>[].obs;
  final selectedItems = <EquipmentModel>[].obs;

  // Step 2: Assign
  final projects = <ProjectModel>[].obs;
  final teamMembers = <ProfileModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final selectedMember = Rxn<ProfileModel>();

  // Step 3: Confirm
  final isSubmitting = false.obs;
  final notes = ''.obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _equipmentRepo.getByStatus('in-storage'),
        _projectRepo.getByStatus('active'),
        _profileRepo.getAll(),
      ]);
      availableEquipment.assignAll(results[0] as List<EquipmentModel>);
      projects.assignAll(results[1] as List<ProjectModel>);
      teamMembers.assignAll(results[2] as List<ProfileModel>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleItem(EquipmentModel item) {
    if (selectedItems.any((e) => e.id == item.id)) {
      selectedItems.removeWhere((e) => e.id == item.id);
    } else {
      selectedItems.add(item);
    }
  }

  bool isItemSelected(String id) =>
      selectedItems.any((e) => e.id == id);

  void addScannedItem(EquipmentModel item) {
    if (!isItemSelected(item.id) && item.isAvailable) {
      selectedItems.add(item);
    }
  }

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool get canProceedToStep2 => selectedItems.isNotEmpty;

  bool get canProceedToStep3 =>
      selectedProject.value != null && selectedMember.value != null;

  Future<void> confirmCheckout() async {
    if (!canProceedToStep3) return;

    isSubmitting.value = true;
    try {
      await _assignmentRepo.checkout(
        equipmentIds: selectedItems.map((e) => e.id).toList(),
        projectId: selectedProject.value!.id,
        checkedOutBy: selectedMember.value!.id,
        notes: notes.value.isNotEmpty ? notes.value : null,
      );

      Get.back();
      Get.snackbar(
        'Success',
        '${selectedItems.length} item(s) checked out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Checkout failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
