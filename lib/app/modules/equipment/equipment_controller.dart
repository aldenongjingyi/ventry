import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/equipment_model.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/equipment_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/providers/equipment_provider.dart';

class EquipmentController extends GetxController {
  final _equipmentRepo = EquipmentRepository();
  final _assignmentRepo = AssignmentRepository();
  final _categoryRepo = CategoryRepository();
  final _equipmentProvider = EquipmentProvider();

  final equipment = <EquipmentModel>[].obs;
  final filteredEquipment = <EquipmentModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final selectedEquipment = Rxn<EquipmentModel>();
  final equipmentHistory = <AssignmentModel>[].obs;

  final isLoading = true.obs;
  final isDetailLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'all'.obs;
  final selectedCategory = 'all'.obs;

  final searchController = TextEditingController();

  RealtimeChannel? _equipmentChannel;

  @override
  void onInit() {
    super.onInit();
    loadEquipment();
    loadCategories();
    _subscribeToChanges();

    // React to filter changes
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    ever(selectedCategory, (_) => _applyFilters());
  }

  Future<void> loadEquipment() async {
    try {
      isLoading.value = true;
      final data = await _equipmentRepo.getAll();
      equipment.assignAll(data);
      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load equipment',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final data = await _categoryRepo.getAll();
      categories.assignAll(data);
    } catch (_) {}
  }

  Future<void> loadEquipmentDetail(String id) async {
    try {
      isDetailLoading.value = true;
      final eq = await _equipmentRepo.getById(id);
      selectedEquipment.value = eq;

      if (eq != null) {
        final history = await _assignmentRepo.getByEquipment(eq.id);
        equipmentHistory.assignAll(history);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load details',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDetailLoading.value = false;
    }
  }

  void _applyFilters() {
    var result = equipment.toList();

    if (selectedStatus.value != 'all') {
      result = result.where((e) => e.status == selectedStatus.value).toList();
    }

    if (selectedCategory.value != 'all') {
      result = result.where((e) => e.categoryId == selectedCategory.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((e) =>
        e.name.toLowerCase().contains(q) ||
        (e.barcode?.toLowerCase().contains(q) ?? false) ||
        (e.serialNumber?.toLowerCase().contains(q) ?? false) ||
        (e.categoryName?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    filteredEquipment.assignAll(result);
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void onStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void onCategoryFilter(String categoryId) {
    selectedCategory.value = categoryId;
  }

  void _subscribeToChanges() {
    _equipmentChannel = _equipmentProvider.subscribeToChanges((_) {
      loadEquipment();
    });
  }

  // Stats getters
  int get totalCount => equipment.length;
  int get inStorageCount => equipment.where((e) => e.status == 'in-storage').length;
  int get checkedOutCount => equipment.where((e) => e.status == 'checked-out').length;
  int get maintenanceCount => equipment.where((e) => e.status == 'maintenance').length;

  @override
  void onClose() {
    searchController.dispose();
    _equipmentChannel?.unsubscribe();
    super.onClose();
  }
}
