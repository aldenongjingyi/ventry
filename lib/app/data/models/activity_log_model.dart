class ActivityLogModel {
  final String id;
  final String organisationId;
  final String userId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? fromStatus;
  final String? toStatus;
  final String? projectId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  // Joined fields
  final String? userName;

  ActivityLogModel({
    required this.id,
    required this.organisationId,
    required this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.fromStatus,
    this.toStatus,
    this.projectId,
    required this.metadata,
    required this.createdAt,
    this.userName,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    final membership = json['org_memberships'];
    return ActivityLogModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String?,
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String?,
      projectId: json['project_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: membership is Map<String, dynamic>
          ? membership['full_name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'from_status': fromStatus,
        'to_status': toStatus,
        'project_id': projectId,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };

  ActivityLogModel copyWith({
    Map<String, dynamic>? metadata,
  }) =>
      ActivityLogModel(
        id: id,
        organisationId: organisationId,
        userId: userId,
        action: action,
        entityType: entityType,
        entityId: entityId,
        fromStatus: fromStatus,
        toStatus: toStatus,
        projectId: projectId,
        metadata: metadata ?? this.metadata,
        createdAt: createdAt,
        userName: userName,
      );

  String get displayAction {
    switch (action) {
      case 'move_to_project':
        return 'moved to project';
      case 'return_to_storage':
        return 'returned to storage';
      case 'mark_missing':
        return 'marked as missing';
      case 'mark_repair':
        return 'sent for repair';
      case 'retire':
        return 'retired';
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
      case 'item':
        return 'item';
      case 'project':
        return 'project';
      default:
        return entityType;
    }
  }
}
