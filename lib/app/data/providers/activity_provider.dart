import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId, {int limit = 50}) async {
    return await _client
        .from('activity_log')
        .select()
        .eq('organisation_id', orgId)
        .order('created_at', ascending: false)
        .limit(limit);
  }

  Future<List<Map<String, dynamic>>> getByEntity(String entityId, {int limit = 20}) async {
    return await _client
        .from('activity_log')
        .select()
        .eq('entity_id', entityId)
        .order('created_at', ascending: false)
        .limit(limit);
  }

  /// Fetches user_id -> full_name map for an org's members.
  Future<Map<String, String>> getMemberNames(String orgId) async {
    final data = await _client
        .from('org_memberships')
        .select('user_id, full_name')
        .eq('organisation_id', orgId);
    return {
      for (final row in data)
        row['user_id'] as String: row['full_name'] as String,
    };
  }

  RealtimeChannel subscribeToChanges(String orgId, void Function(dynamic) callback) {
    return _client
        .channel('activity_$orgId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'activity_log',
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
