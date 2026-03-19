import '../models/activity_log_model.dart';
import '../providers/activity_provider.dart';

class ActivityRepository {
  final ActivityProvider _provider;

  ActivityRepository({ActivityProvider? provider})
      : _provider = provider ?? ActivityProvider();

  Future<List<ActivityLogModel>> getByOrg(String orgId, {int limit = 50}) async {
    final data = await _provider.getByOrg(orgId, limit: limit);
    return data.map((e) => ActivityLogModel.fromJson(e)).toList();
  }

  Future<List<ActivityLogModel>> getByEntity(String entityId, {int limit = 20}) async {
    final data = await _provider.getByEntity(entityId, limit: limit);
    return data.map((e) => ActivityLogModel.fromJson(e)).toList();
  }
}
