class OrgMembershipModel {
  final String id;
  final String userId;
  final String organisationId;
  final String role;
  final String fullName;
  final DateTime createdAt;

  OrgMembershipModel({
    required this.id,
    required this.userId,
    required this.organisationId,
    required this.role,
    required this.fullName,
    required this.createdAt,
  });

  factory OrgMembershipModel.fromJson(Map<String, dynamic> json) =>
      OrgMembershipModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        organisationId: json['organisation_id'] as String,
        role: json['role'] as String,
        fullName: json['full_name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'organisation_id': organisationId,
        'role': role,
        'full_name': fullName,
        'created_at': createdAt.toIso8601String(),
      };

  OrgMembershipModel copyWith({
    String? role,
    String? fullName,
  }) =>
      OrgMembershipModel(
        id: id,
        userId: userId,
        organisationId: organisationId,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        createdAt: createdAt,
      );

  bool get isAdmin => role == 'admin';
}
