import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ActivityProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getRecent({int limit = 20}) async {
    return await _client
        .from('activity_log')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .limit(limit);
  }

  RealtimeChannel subscribeToChanges(void Function(dynamic) callback) {
    return _client
        .channel('activity_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'activity_log',
          callback: (payload) => callback(payload),
        )
        .subscribe();
  }
}
