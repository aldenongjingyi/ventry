import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class MemberProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId) async {
    return await _client
        .from('org_memberships')
        .select()
        .eq('organisation_id', orgId)
        .order('created_at');
  }

  Future<Map<String, dynamic>?> getCurrentUserMembership(String orgId) async {
    final userId = SupabaseService.to.userId!;
    return await _client
        .from('org_memberships')
        .select()
        .eq('organisation_id', orgId)
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<void> updateRole(String membershipId, String role) async {
    await _client
        .from('org_memberships')
        .update({'role': role})
        .eq('id', membershipId);
  }

  Future<void> remove(String membershipId) async {
    await _client
        .from('org_memberships')
        .delete()
        .eq('id', membershipId);
  }

  Future<Map<String, dynamic>> invite(String orgId, String userId, String fullName, String role) async {
    return await _client
        .from('org_memberships')
        .insert({
          'organisation_id': orgId,
          'user_id': userId,
          'full_name': fullName,
          'role': role,
        })
        .select()
        .single();
  }

  RealtimeChannel subscribeToChanges(String orgId, void Function(dynamic) callback) {
    return _client
        .channel('members_$orgId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'org_memberships',
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
