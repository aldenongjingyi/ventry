import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ItemProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId) async {
    return await _client
        .from('items')
        .select('*, projects(name)')
        .eq('organisation_id', orgId)
        .order('item_number');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('items')
        .select('*, projects(name)')
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getByQrCode(String qrCode) async {
    return await _client
        .from('items')
        .select('*, projects(name)')
        .eq('qr_code', qrCode)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getByProject(String projectId) async {
    return await _client
        .from('items')
        .select('*, projects(name)')
        .eq('project_id', projectId)
        .order('item_number');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    return await _client
        .from('items')
        .insert(data)
        .select()
        .single();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from('items').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('items').delete().eq('id', id);
  }

  RealtimeChannel subscribeToChanges(String orgId, void Function(dynamic) callback) {
    return _client
        .channel('items_$orgId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'organisation_id',
            value: orgId,
          ),
          callback: (payload) => callback(payload),
        )
        .subscribe();
  }
}
