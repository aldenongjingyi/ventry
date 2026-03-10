import '../models/assignment_model.dart';
import '../providers/assignment_provider.dart';

class AssignmentRepository {
  final AssignmentProvider _provider;

  AssignmentRepository({AssignmentProvider? provider})
      : _provider = provider ?? AssignmentProvider();

  Future<List<AssignmentModel>> getActive() async {
    final data = await _provider.getActive();
    return data.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<List<AssignmentModel>> getByEquipment(String equipmentId) async {
    final data = await _provider.getByEquipment(equipmentId);
    return data.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<List<AssignmentModel>> getActiveByProject(String projectId) async {
    final data = await _provider.getActiveByProject(projectId);
    return data.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  Future<void> checkout({
    required List<String> equipmentIds,
    required String projectId,
    required String checkedOutBy,
    String? notes,
  }) async {
    await _provider.checkout(equipmentIds, projectId, checkedOutBy, notes: notes);
  }

  Future<void> checkin({
    required List<String> assignmentIds,
    required Map<String, String> conditions,
  }) async {
    await _provider.checkin(assignmentIds, conditions);
  }
}
