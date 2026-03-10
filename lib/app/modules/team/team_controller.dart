import 'package:get/get.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class TeamController extends GetxController {
  final _profileRepo = ProfileRepository();

  final members = <ProfileModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      final data = await _profileRepo.getAll();
      members.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load team',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
