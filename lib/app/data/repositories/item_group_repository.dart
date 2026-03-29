import '../models/item_group_model.dart';
import '../providers/item_group_provider.dart';

class ItemGroupRepository {
  final ItemGroupProvider _provider;

  ItemGroupRepository({ItemGroupProvider? provider})
      : _provider = provider ?? ItemGroupProvider();

  Future<List<ItemGroupModel>> getByOrg(String orgId) async {
    final data = await _provider.getByOrg(orgId);
    return data.map((e) => ItemGroupModel.fromJson(e)).toList();
  }

  Future<ItemGroupModel> create(String orgId, String name) async {
    final data = await _provider.create({
      'organisation_id': orgId,
      'name': name,
    });
    return ItemGroupModel.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _provider.delete(id);
  }
}
