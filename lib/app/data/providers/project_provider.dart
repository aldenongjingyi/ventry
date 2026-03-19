import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ProjectProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId) async {
    return await _client
        .from('projects')
        .select('*, items(count)')
        .eq('organisation_id', orgId)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('projects')
        .select('*, items(count)')
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    return await _client
        .from('projects')
        .insert(data)
        .select()
        .single();
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from('projects').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  RealtimeChannel subscribeToChanges(String orgId, void Function(dynamic) callback) {
    return _client
        .channel('projects_$orgId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'projects',
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
