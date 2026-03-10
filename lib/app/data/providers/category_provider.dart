import '../services/supabase_service.dart';

class CategoryProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _client
        .from('categories')
        .select()
        .order('name');
  }
}
