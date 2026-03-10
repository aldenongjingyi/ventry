import '../models/profile_model.dart';
import '../providers/profile_provider.dart';

class ProfileRepository {
  final ProfileProvider _provider;

  ProfileRepository({ProfileProvider? provider})
      : _provider = provider ?? ProfileProvider();

  Future<List<ProfileModel>> getAll() async {
    final data = await _provider.getAll();
    return data.map((e) => ProfileModel.fromJson(e)).toList();
  }

  Future<ProfileModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel?> getCurrentProfile() async {
    final data = await _provider.getCurrentProfile();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }
}
