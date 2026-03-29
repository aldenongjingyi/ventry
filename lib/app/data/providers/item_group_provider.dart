import '../services/supabase_service.dart';

class ItemGroupProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId) async {
    return await _client
        .from('item_groups')
        .select()
        .eq('organisation_id', orgId)
        .order('name');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    return await _client
        .from('item_groups')
        .insert(data)
        .select()
        .single();
  }

  Future<void> delete(String id) async {
    await _client.from('item_groups').delete().eq('id', id);
  }
}
