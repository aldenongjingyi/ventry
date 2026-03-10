import '../models/equipment_model.dart';
import '../providers/equipment_provider.dart';

class EquipmentRepository {
  final EquipmentProvider _provider;

  EquipmentRepository({EquipmentProvider? provider})
      : _provider = provider ?? EquipmentProvider();

  Future<List<EquipmentModel>> getAll() async {
    final data = await _provider.getAll();
    return data.map((e) => EquipmentModel.fromJson(e)).toList();
  }

  Future<EquipmentModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return EquipmentModel.fromJson(data);
  }

  Future<EquipmentModel?> getByBarcode(String barcode) async {
    final data = await _provider.getByBarcode(barcode);
    if (data == null) return null;
    return EquipmentModel.fromJson(data);
  }

  Future<List<EquipmentModel>> getByStatus(String status) async {
    final all = await getAll();
    return all.where((e) => e.status == status).toList();
  }

  Future<List<EquipmentModel>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all.where((e) =>
      e.name.toLowerCase().contains(q) ||
      (e.barcode?.toLowerCase().contains(q) ?? false) ||
      (e.serialNumber?.toLowerCase().contains(q) ?? false) ||
      (e.categoryName?.toLowerCase().contains(q) ?? false)
    ).toList();
  }
}
