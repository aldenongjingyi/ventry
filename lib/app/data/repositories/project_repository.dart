import '../models/project_model.dart';
import '../providers/project_provider.dart';

class ProjectRepository {
  final ProjectProvider _provider;

  ProjectRepository({ProjectProvider? provider})
      : _provider = provider ?? ProjectProvider();

  Future<List<ProjectModel>> getAll() async {
    final data = await _provider.getAll();
    return data.map((e) => ProjectModel.fromJson(e)).toList();
  }

  Future<ProjectModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return ProjectModel.fromJson(data);
  }

  Future<List<ProjectModel>> getByStatus(String status) async {
    final all = await getAll();
    return all.where((p) => p.status == status).toList();
  }
}
