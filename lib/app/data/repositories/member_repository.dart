import '../models/org_membership_model.dart';
import '../providers/member_provider.dart';

class MemberRepository {
  final MemberProvider _provider;

  MemberRepository({MemberProvider? provider})
      : _provider = provider ?? MemberProvider();

  Future<List<OrgMembershipModel>> getByOrg(String orgId) async {
    final data = await _provider.getByOrg(orgId);
    return data.map((e) => OrgMembershipModel.fromJson(e)).toList();
  }

  Future<OrgMembershipModel?> getCurrentUserMembership(String orgId) async {
    final data = await _provider.getCurrentUserMembership(orgId);
    if (data == null) return null;
    return OrgMembershipModel.fromJson(data);
  }

  Future<void> updateRole(String membershipId, String role) async {
    await _provider.updateRole(membershipId, role);
  }

  Future<void> remove(String membershipId) async {
    await _provider.remove(membershipId);
  }
}
