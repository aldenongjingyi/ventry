class ItemModel {
  final String id;
  final String organisationId;
  final String name;
  final int itemNumber;
  final int? sequentialId;
  final String status;
  final String? projectId;
  final String qrCode;
  final String? labelColor;
  final String? itemGroupId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? projectName;
  final String? itemGroupName;

  ItemModel({
    required this.id,
    required this.organisationId,
    required this.name,
    required this.itemNumber,
    this.sequentialId,
    required this.status,
    this.projectId,
    required this.qrCode,
    this.labelColor,
    this.itemGroupId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.projectName,
    this.itemGroupName,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final project = json['projects'];
    final group = json['item_groups'];
    return ItemModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      name: json['name'] as String,
      itemNumber: json['item_number'] as int,
      sequentialId: json['sequential_id'] as int?,
      status: json['status'] as String? ?? 'storage',
      projectId: json['project_id'] as String?,
      qrCode: json['qr_code'] as String,
      labelColor: json['label_color'] as String?,
      itemGroupId: json['item_group_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      projectName:
          project is Map<String, dynamic> ? project['name'] as String? : null,
      itemGroupName:
          group is Map<String, dynamic> ? group['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'name': name,
        'item_number': itemNumber,
        'sequential_id': sequentialId,
        'status': status,
        'project_id': projectId,
        'qr_code': qrCode,
        'label_color': labelColor,
        'item_group_id': itemGroupId,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ItemModel copyWith({
    String? name,
    String? status,
    String? projectId,
    String? labelColor,
    String? itemGroupId,
    String? notes,
    String? projectName,
    String? itemGroupName,
  }) =>
      ItemModel(
        id: id,
        organisationId: organisationId,
        name: name ?? this.name,
        itemNumber: itemNumber,
        sequentialId: sequentialId,
        status: status ?? this.status,
        projectId: projectId ?? this.projectId,
        qrCode: qrCode,
        labelColor: labelColor ?? this.labelColor,
        itemGroupId: itemGroupId ?? this.itemGroupId,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        projectName: projectName ?? this.projectName,
        itemGroupName: itemGroupName ?? this.itemGroupName,
      );

  bool get isInStorage => status == 'storage';
  bool get isInProject => status == 'in_project';
  bool get isMissing => status == 'missing';
  bool get isRetired => status == 'retired';

  String get displayId => sequentialId != null ? '#$sequentialId' : '#$itemNumber';

  String get displayStatus {
    switch (status) {
      case 'storage':
        return 'In Storage';
      case 'in_project':
        return 'In Project';
      case 'missing':
        return 'Missing';
      case 'under_repair':
        return 'Under Repair';
      case 'retired':
        return 'Retired';
      default:
        return status;
    }
  }
}
