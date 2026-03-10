class AssignmentModel {
  final String id;
  final String companyId;
  final String equipmentId;
  final String? projectId;
  final String checkedOutBy;
  final DateTime checkedOutAt;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final String? conditionOnReturn;
  final String? notes;
  final DateTime createdAt;

  // Joined fields
  final String? equipmentName;
  final String? equipmentBarcode;
  final String? projectName;
  final String? checkedOutByName;

  AssignmentModel({
    required this.id,
    required this.companyId,
    required this.equipmentId,
    this.projectId,
    required this.checkedOutBy,
    required this.checkedOutAt,
    this.checkedInAt,
    this.checkedInBy,
    this.conditionOnReturn,
    this.notes,
    required this.createdAt,
    this.equipmentName,
    this.equipmentBarcode,
    this.projectName,
    this.checkedOutByName,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final equipment = json['equipment'];
    final project = json['projects'];
    final profile = json['profiles'];

    return AssignmentModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      equipmentId: json['equipment_id'] as String,
      projectId: json['project_id'] as String?,
      checkedOutBy: json['checked_out_by'] as String,
      checkedOutAt: DateTime.parse(json['checked_out_at'] as String),
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      checkedInBy: json['checked_in_by'] as String?,
      conditionOnReturn: json['condition_on_return'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      equipmentName: equipment is Map<String, dynamic>
          ? equipment['name'] as String?
          : null,
      equipmentBarcode: equipment is Map<String, dynamic>
          ? equipment['barcode'] as String?
          : null,
      projectName:
          project is Map<String, dynamic> ? project['name'] as String? : null,
      checkedOutByName: profile is Map<String, dynamic>
          ? profile['full_name'] as String?
          : null,
    );
  }

  bool get isActive => checkedInAt == null;
}
