import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../services/supabase_service.dart';

class ProjectRepository {
  final ProjectProvider _provider;

  ProjectRepository({ProjectProvider? provider})
      : _provider = provider ?? ProjectProvider();

  Future<List<ProjectModel>> getByOrg(String orgId) async {
    final data = await _provider.getByOrg(orgId);
    return data.map((e) => ProjectModel.fromJson(e)).toList();
  }

  Future<ProjectModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return ProjectModel.fromJson(data);
  }

  Future<List<ProjectModel>> getByStatus(String orgId, String status) async {
    final all = await getByOrg(orgId);
    return all.where((p) => p.status == status).toList();
  }

  Future<ProjectModel> create(String orgId, String name, String? location) async {
    final data = await _provider.create({
      'organisation_id': orgId,
      'name': name,
      'location': location,
    });
    return ProjectModel.fromJson(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _provider.update(id, data);
  }

  Future<void> delete(String id) async {
    await _provider.delete(id);
  }

  Future<void> complete(String projectId, String action) async {
    await SupabaseService.to.client.rpc('complete_project', params: {
      'p_project_id': projectId,
      'p_action': action,
    });
  }
}
