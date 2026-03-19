import '../models/organisation_model.dart';
import '../providers/org_provider.dart';

class OrgRepository {
  final OrgProvider _provider;

  OrgRepository({OrgProvider? provider})
      : _provider = provider ?? OrgProvider();

  Future<List<OrganisationModel>> getUserOrgs() async {
    final data = await _provider.getUserOrgs();
    return data.map((e) => OrganisationModel.fromJson(e)).toList();
  }

  Future<OrganisationModel?> getById(String id) async {
    final data = await _provider.getById(id);
    if (data == null) return null;
    return OrganisationModel.fromJson(data);
  }
}
