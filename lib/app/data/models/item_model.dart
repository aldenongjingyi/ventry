class ItemModel {
  final String id;
  final String organisationId;
  final String name;
  final int itemNumber;
  final String status;
  final String? projectId;
  final String qrCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? projectName;

  ItemModel({
    required this.id,
    required this.organisationId,
    required this.name,
    required this.itemNumber,
    required this.status,
    this.projectId,
    required this.qrCode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.projectName,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final project = json['projects'];
    return ItemModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      name: json['name'] as String,
      itemNumber: json['item_number'] as int,
      status: json['status'] as String? ?? 'storage',
      projectId: json['project_id'] as String?,
      qrCode: json['qr_code'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      projectName:
          project is Map<String, dynamic> ? project['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'name': name,
        'item_number': itemNumber,
        'status': status,
        'project_id': projectId,
        'qr_code': qrCode,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ItemModel copyWith({
    String? name,
    String? status,
    String? projectId,
    String? notes,
    String? projectName,
  }) =>
      ItemModel(
        id: id,
        organisationId: organisationId,
        name: name ?? this.name,
        itemNumber: itemNumber,
        status: status ?? this.status,
        projectId: projectId ?? this.projectId,
        qrCode: qrCode,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        projectName: projectName ?? this.projectName,
      );

  bool get isInStorage => status == 'storage';
  bool get isInProject => status == 'in_project';
  bool get isMissing => status == 'missing';
  bool get isRetired => status == 'retired';

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
