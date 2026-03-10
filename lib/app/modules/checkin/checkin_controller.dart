import 'package:get/get.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';

class CheckinController extends GetxController {
  final _assignmentRepo = AssignmentRepository();

  final currentStep = 0.obs;
  final activeAssignments = <AssignmentModel>[].obs;
  final selectedAssignments = <AssignmentModel>[].obs;
  final conditions = <String, String>{}.obs; // assignment_id -> condition
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadActiveAssignments();
  }

  Future<void> _loadActiveAssignments() async {
    try {
      isLoading.value = true;
      final data = await _assignmentRepo.getActive();
      activeAssignments.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assignments',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAssignment(AssignmentModel assignment) {
    if (selectedAssignments.any((a) => a.id == assignment.id)) {
      selectedAssignments.removeWhere((a) => a.id == assignment.id);
      conditions.remove(assignment.id);
    } else {
      selectedAssignments.add(assignment);
      conditions[assignment.id] = 'good';
    }
  }

  bool isAssignmentSelected(String id) =>
      selectedAssignments.any((a) => a.id == id);

  void setCondition(String assignmentId, String condition) {
    conditions[assignmentId] = condition;
  }

  String getCondition(String assignmentId) =>
      conditions[assignmentId] ?? 'good';

  void nextStep() {
    if (currentStep.value < 1) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  bool get canProceed => selectedAssignments.isNotEmpty;

  Future<void> confirmCheckin() async {
    if (!canProceed) return;

    isSubmitting.value = true;
    try {
      await _assignmentRepo.checkin(
        assignmentIds: selectedAssignments.map((a) => a.id).toList(),
        conditions: Map<String, String>.from(conditions),
      );

      Get.back();
      Get.snackbar(
        'Success',
        '${selectedAssignments.length} item(s) checked in',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Check-in failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
