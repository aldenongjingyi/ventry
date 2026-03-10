class ProfileModel {
  final String id;
  final String companyId;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        companyId: json['company_id'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'full_name': fullName,
        'role': role,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };

  ProfileModel copyWith({String? fullName, String? role, String? avatarUrl}) =>
      ProfileModel(
        id: id,
        companyId: companyId,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.substring(0, fullName.length >= 2 ? 2 : 1).toUpperCase();
  }
}
