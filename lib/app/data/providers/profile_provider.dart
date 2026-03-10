import '../services/supabase_service.dart';

class ProfileProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _client
        .from('profiles')
        .select()
        .order('full_name');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final userId = SupabaseService.to.userId;
    if (userId == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }
}
