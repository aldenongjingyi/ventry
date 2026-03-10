import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class EquipmentProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _client
        .from('equipment')
        .select('*, categories(*)')
        .order('name');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('equipment')
        .select('*, categories(*)')
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getByBarcode(String barcode) async {
    return await _client
        .from('equipment')
        .select('*, categories(*)')
        .eq('barcode', barcode)
        .maybeSingle();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from('equipment').update(data).eq('id', id);
  }

  RealtimeChannel subscribeToChanges(void Function(dynamic) callback) {
    return _client
        .channel('equipment_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'equipment',
          callback: (payload) => callback(payload),
        )
        .subscribe();
  }
}
