import '../models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityRepository {
  final ActivityProvider _provider;

  ActivityRepository({ActivityProvider? provider})
      : _provider = provider ?? ActivityProvider();

  Future<List<ActivityModel>> getRecent({int limit = 20}) async {
    final data = await _provider.getRecent(limit: limit);
    return data.map((e) => ActivityModel.fromJson(e)).toList();
  }
}
