import '../services/supabase_service.dart';

class ProjectProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _client
        .from('projects')
        .select()
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _client
        .from('projects')
        .select()
        .eq('id', id)
        .maybeSingle();
  }
}
