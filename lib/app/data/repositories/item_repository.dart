import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../services/supabase_service.dart';

class ItemRepository {
  final ItemProvider _provider;

  ItemRepository({ItemProvider? provider})
      : _provider = provider ?? ItemProvider();

  Future<List<ItemModel>> getByOrg(String orgId) async {
    final data = await _provider.getByOrg(orgId);
    return data.map((e) => ItemModel.fromJson(e)).toList();
  }

  Future<ItemModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return ItemModel.fromJson(data);
  }

  Future<ItemModel?> getByQrCode(String qrCode) async {
    final data = await _provider.getByQrCode(qrCode);
    if (data == null) return null;
    return ItemModel.fromJson(data);
  }

  Future<List<ItemModel>> getByProject(String projectId) async {
    final data = await _provider.getByProject(projectId);
    return data.map((e) => ItemModel.fromJson(e)).toList();
  }

  Future<List<ItemModel>> getByStatus(String orgId, String status) async {
    final all = await getByOrg(orgId);
    return all.where((e) => e.status == status).toList();
  }

  Future<List<ItemModel>> search(String orgId, String query) async {
    final all = await getByOrg(orgId);
    final q = query.toLowerCase();
    return all.where((e) =>
      e.name.toLowerCase().contains(q) ||
      e.itemNumber.toString().contains(q) ||
      (e.projectName?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  /// Creates [quantity] items with the given name, auto-assigning sequential IDs.
  Future<List<String>> createBatch({
    required String orgId,
    required String name,
    required int quantity,
    String? labelColor,
    String? itemGroupId,
    String? notes,
  }) async {
    final result = await SupabaseService.to.client.rpc('create_items_batch', params: {
      'p_org_id': orgId,
      'p_name': name,
      'p_quantity': quantity,
      'p_label_color': labelColor,
      'p_item_group_id': itemGroupId,
      'p_notes': notes,
    });
    return (result as List).cast<String>();
  }

  /// Single item create — delegates to batch with quantity 1.
  Future<void> create(String orgId, String name, String? notes) async {
    await createBatch(orgId: orgId, name: name, quantity: 1, notes: notes);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _provider.update(id, {...data, 'updated_at': DateTime.now().toIso8601String()});
  }

  Future<void> delete(String id) async {
    await _provider.delete(id);
  }

  Future<void> relocate(String itemId, String targetStatus, {String? projectId}) async {
    await SupabaseService.to.client.rpc('perform_relocation', params: {
      'p_item_id': itemId,
      'p_target_status': targetStatus,
      'p_project_id': projectId,
    });
  }
}
