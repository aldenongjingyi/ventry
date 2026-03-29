import '../models/activity_log_model.dart';
import '../providers/activity_provider.dart';

class ActivityRepository {
  final ActivityProvider _provider;

  ActivityRepository({ActivityProvider? provider})
      : _provider = provider ?? ActivityProvider();

  Future<List<ActivityLogModel>> getByOrg(String orgId, {int limit = 50}) async {
    final results = await Future.wait([
      _provider.getByOrg(orgId, limit: limit),
      _provider.getMemberNames(orgId),
    ]);
    final data = results[0] as List<Map<String, dynamic>>;
    final names = results[1] as Map<String, String>;
    return data.map((e) {
      final model = ActivityLogModel.fromJson(e);
      final name = names[model.userId];
      return name != null
          ? ActivityLogModel(
              id: model.id,
              organisationId: model.organisationId,
              userId: model.userId,
              action: model.action,
              entityType: model.entityType,
              entityId: model.entityId,
              fromStatus: model.fromStatus,
              toStatus: model.toStatus,
              projectId: model.projectId,
              metadata: model.metadata,
              createdAt: model.createdAt,
              userName: name,
            )
          : model;
    }).toList();
  }

  Future<List<ActivityLogModel>> getByEntity(String entityId, {int limit = 20}) async {
    final data = await _provider.getByEntity(entityId, limit: limit);
    // For entity-level queries we don't have orgId readily, so names stay as-is
    // The caller (item detail) can enrich if needed
    return data.map((e) => ActivityLogModel.fromJson(e)).toList();
  }
}
