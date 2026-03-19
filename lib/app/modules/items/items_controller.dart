import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/item_model.dart';
import '../../data/providers/item_provider.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../theme/app_colors.dart';

class ItemsController extends GetxController {
  final _repo = ItemRepository();
  final _provider = ItemProvider();
  final items = <ItemModel>[].obs;
  final filteredItems = <ItemModel>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final searchQuery = ''.obs;
  final filterStatus = ''.obs;

  // Bulk selection
  final isSelecting = false.obs;
  final selectedIds = <String>{}.obs;

  RealtimeChannel? _channel;

  String get orgId => SupabaseService.to.activeOrgId.value ?? '';

  @override
  void onInit() {
    super.onInit();
    loadItems();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    if (orgId.isEmpty) return;
    _channel = _provider.subscribeToChanges(orgId, (_) => loadItems());
  }

  Future<void> loadItems() async {
    if (orgId.isEmpty) return;
    isLoading.value = true;
    hasError.value = false;
    try {
      items.value = await _repo.getByOrg(orgId);
      _applyFilters();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setFilterStatus(String status) {
    filterStatus.value = filterStatus.value == status ? '' : status;
    _applyFilters();
  }

  void _applyFilters() {
    var result = items.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.itemNumber.toString().contains(q)
      ).toList();
    }
    if (filterStatus.value.isNotEmpty) {
      result = result.where((i) => i.status == filterStatus.value).toList();
    }
    filteredItems.value = result;
  }

  Future<ItemModel?> createItem(String name, String? notes) async {
    try {
      final item = await _repo.create(orgId, name, notes);
      await loadItems();
      SupabaseService.to.loadOrgUsage();
      return item;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surfaceElevated,
        colorText: AppColors.error,
      );
      return null;
    }
  }

  void toggleSelecting() {
    isSelecting.value = !isSelecting.value;
    if (!isSelecting.value) selectedIds.clear();
  }

  void toggleSelected(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  List<ItemModel> get selectedItems =>
      items.where((i) => selectedIds.contains(i.id)).toList();

  Future<void> deleteItem(String id) async {
    await _repo.delete(id);
    await loadItems();
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }
}
