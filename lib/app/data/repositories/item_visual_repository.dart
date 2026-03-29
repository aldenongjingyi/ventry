import 'dart:typed_data';
import '../models/item_visual_model.dart';
import '../providers/item_visual_provider.dart';

class ItemVisualRepository {
  final ItemVisualProvider _provider;

  ItemVisualRepository({ItemVisualProvider? provider})
      : _provider = provider ?? ItemVisualProvider();

  Future<List<ItemVisualModel>> getByOrg(String orgId) async {
    final data = await _provider.getByOrg(orgId);
    return data.map((e) => ItemVisualModel.fromJson(e)).toList();
  }

  Future<ItemVisualModel?> getByItemName(String orgId, String itemName) async {
    final data = await _provider.getByItemName(orgId, itemName);
    if (data == null) return null;
    return ItemVisualModel.fromJson(data);
  }

  /// Set an icon for an item name.
  Future<ItemVisualModel> setIcon(String orgId, String itemName, String iconName) async {
    final data = await _provider.upsert({
      'organisation_id': orgId,
      'item_name': itemName,
      'visual_type': 'icon',
      'visual_value': iconName,
      'updated_at': DateTime.now().toIso8601String(),
    });
    return ItemVisualModel.fromJson(data);
  }

  /// Upload a photo and set it for an item name.
  Future<ItemVisualModel> setPhoto(String orgId, String itemName, Uint8List bytes) async {
    final url = await _provider.uploadPhoto(orgId, itemName, bytes);
    final data = await _provider.upsert({
      'organisation_id': orgId,
      'item_name': itemName,
      'visual_type': 'photo',
      'visual_value': url,
      'updated_at': DateTime.now().toIso8601String(),
    });
    return ItemVisualModel.fromJson(data);
  }
}
