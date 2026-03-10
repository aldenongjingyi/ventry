class ActivityModel {
  final String id;
  final String companyId;
  final String userId;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  // Joined
  final String? userName;

  ActivityModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.details,
    required this.createdAt,
    this.userName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return ActivityModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      details: (json['details'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: profile is Map<String, dynamic>
          ? profile['full_name'] as String?
          : null,
    );
  }

  String get displayAction {
    switch (action) {
      case 'checkout':
        return 'checked out';
      case 'checkin':
        return 'checked in';
      case 'create':
        return 'added';
      case 'update':
        return 'updated';
      default:
        return action;
    }
  }

  String get displayEntity {
    switch (entityType) {
      case 'equipment':
        return 'equipment';
      case 'project':
        return 'project';
      default:
        return entityType;
    }
  }
}
