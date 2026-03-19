import 'package:get/get.dart';
import '../../data/models/item_model.dart';
import '../../data/models/activity_log_model.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/activity_repository.dart';
import '../../theme/app_colors.dart';

class ItemDetailController extends GetxController {
  final _itemRepo = ItemRepository();
  final _activityRepo = ActivityRepository();

  final item = Rxn<ItemModel>();
  final activities = <ActivityLogModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  late final String itemId;

  @override
  void onInit() {
    super.onInit();
    itemId = Get.parameters['id'] ?? '';
    if (itemId.isNotEmpty) loadItem();
  }

  Future<void> loadItem() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      item.value = await _itemRepo.getById(itemId);
      if (item.value != null) {
        activities.value = await _activityRepo.getByEntity(itemId);
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem() async {
    try {
      await _itemRepo.delete(itemId);
      Get.back();
      Get.snackbar('Deleted', 'Item has been removed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
    }
  }
}
