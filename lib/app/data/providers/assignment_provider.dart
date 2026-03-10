import '../services/supabase_service.dart';

class AssignmentProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getActive() async {
    return await _client
        .from('equipment_assignments')
        .select('*, equipment(*), projects(*), profiles(*)')
        .isFilter('checked_in_at', null)
        .order('checked_out_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getByEquipment(String equipmentId) async {
    return await _client
        .from('equipment_assignments')
        .select('*, equipment(*), projects(*), profiles(*)')
        .eq('equipment_id', equipmentId)
        .order('checked_out_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getActiveByProject(String projectId) async {
    return await _client
        .from('equipment_assignments')
        .select('*, equipment(*), profiles(*)')
        .eq('project_id', projectId)
        .isFilter('checked_in_at', null)
        .order('checked_out_at', ascending: false);
  }

  Future<void> checkout(List<String> equipmentIds, String projectId, String checkedOutBy, {String? notes}) async {
    await _client.rpc('perform_checkout', params: {
      'p_equipment_ids': equipmentIds,
      'p_project_id': projectId,
      'p_checked_out_by': checkedOutBy,
      'p_notes': notes,
    });
  }

  Future<void> checkin(List<String> assignmentIds, Map<String, String> conditions) async {
    await _client.rpc('perform_checkin', params: {
      'p_assignment_ids': assignmentIds,
      'p_conditions': conditions,
    });
  }
}
