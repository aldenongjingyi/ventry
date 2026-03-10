import 'package:get/get.dart';
import '../models/equipment_model.dart';
import 'supabase_service.dart';

class ScannerService extends GetxService {
  static ScannerService get to => Get.find();

  final _supabase = SupabaseService.to;

  Future<EquipmentModel?> lookupBarcode(String barcode) async {
    final response = await _supabase.client
        .from('equipment')
        .select('*, categories(*)')
        .eq('barcode', barcode)
        .maybeSingle();

    if (response == null) return null;
    return EquipmentModel.fromJson(response);
  }
}
