import 'dart:async';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/item_model.dart';
import '../../data/models/item_group_model.dart';
import '../../data/models/item_visual_model.dart';
import '../../data/providers/item_provider.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/item_group_repository.dart';
import '../../data/repositories/item_visual_repository.dart';
import '../../data/services/supabase_service.dart';
import '../../theme/app_colors.dart';

class ItemsController extends GetxController {
  final _repo = ItemRepository();
  final _groupRepo = ItemGroupRepository();
  final _visualRepo = ItemVisualRepository();
  final _provider = ItemProvider();
  final items = <ItemModel>[].obs;
  final filteredItems = <ItemModel>[].obs;
  final itemGroups = <ItemGroupModel>[].obs;
  final itemVisuals = <String, ItemVisualModel>{}.obs; // keyed by lowercase item name
  final isLoading = true.obs;
  final hasError = false.obs;
  final searchQuery = ''.obs;
  final filterStatus = ''.obs;
  final filterGroupId = ''.obs;

  // Bulk selection
  final isSelecting = false.obs;
  final selectedIds = <String>{}.obs;

  Timer? _searchDebounce;
  RealtimeChannel? _channel;

  String get orgId => SupabaseService.to.activeOrgId.value ?? '';

  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadItemGroups();
    loadItemVisuals();
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

  Future<void> loadItemGroups() async {
    if (orgId.isEmpty) return;
    try {
      itemGroups.value = await _groupRepo.getByOrg(orgId);
    } catch (_) {}
  }

  Future<void> loadItemVisuals() async {
    if (orgId.isEmpty) return;
    try {
      final visuals = await _visualRepo.getByOrg(orgId);
      itemVisuals.value = {
        for (final v in visuals) v.itemName.toLowerCase(): v,
      };
    } catch (_) {}
  }

  /// Get the visual for a given item name (case-insensitive).
  ItemVisualModel? getVisual(String itemName) {
    return itemVisuals[itemName.toLowerCase()];
  }

  Future<ItemGroupModel> createItemGroup(String name) async {
    final group = await _groupRepo.create(orgId, name);
    await loadItemGroups();
    return group;
  }

  Future<void> setItemIcon(String itemName, String iconName) async {
    await _visualRepo.setIcon(orgId, itemName, iconName);
    await loadItemVisuals();
  }

  Future<void> setItemPhoto(String itemName, Uint8List bytes) async {
    await _visualRepo.setPhoto(orgId, itemName, bytes);
    await loadItemVisuals();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void setFilterStatus(String status) {
    filterStatus.value = filterStatus.value == status ? '' : status;
    _applyFilters();
  }

  void setFilterGroup(String groupId) {
    filterGroupId.value = filterGroupId.value == groupId ? '' : groupId;
    _applyFilters();
  }

  void selectAll() {
    selectedIds.addAll(filteredItems.map((i) => i.id));
  }

  void deselectAll() {
    selectedIds.clear();
  }

  void _applyFilters() {
    var result = items.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.itemNumber.toString().contains(q) ||
        (i.itemGroupName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (filterStatus.value.isNotEmpty) {
      result = result.where((i) => i.status == filterStatus.value).toList();
    }
    if (filterGroupId.value.isNotEmpty) {
      result = result.where((i) => i.itemGroupId == filterGroupId.value).toList();
    }
    filteredItems.value = result;
  }

  /// Legacy single-item create (used by items_list_view).
  Future<ItemModel?> createItem(String name, String? notes) async {
    try {
      final ids = await _repo.createBatch(
        orgId: orgId,
        name: name,
        quantity: 1,
        notes: notes,
      );
      await loadItems();
      SupabaseService.to.loadOrgUsage();
      if (ids.isNotEmpty) {
        return items.firstWhereOrNull((i) => i.id == ids.first);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
      return null;
    }
  }

  /// Batch create with all options.
  Future<bool> createItems({
    required String name,
    required int quantity,
    String? labelColor,
    String? itemGroupId,
    String? notes,
  }) async {
    try {
      await _repo.createBatch(
        orgId: orgId,
        name: name,
        quantity: quantity,
        labelColor: labelColor,
        itemGroupId: itemGroupId,
        notes: notes,
      );
      await loadItems();
      SupabaseService.to.loadOrgUsage();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create items',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface3,
        colorText: AppColors.reText,
      );
      return false;
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
    _searchDebounce?.cancel();
    _channel?.unsubscribe();
    super.onClose();
  }
}
