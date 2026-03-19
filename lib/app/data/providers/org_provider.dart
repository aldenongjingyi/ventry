import '../services/supabase_service.dart';

class OrgProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getUserOrgs() async {
    final userId = SupabaseService.to.userId!;
    final memberships = await _client
        .from('org_memberships')
        .select('organisation_id')
        .eq('user_id', userId);

    final orgIds = (memberships as List).map((m) => m['organisation_id'] as String).toList();
    if (orgIds.isEmpty) return [];

    return await _client
        .from('organisations')
        .select()
        .inFilter('id', orgIds)
        .order('created_at');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('organisations')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> create(String name) async {
    final result = await _client
        .from('organisations')
        .insert({'name': name})
        .select()
        .single();
    return result;
  }
}
