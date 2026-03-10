class ProjectModel {
  final String id;
  final String companyId;
  final String name;
  final String? clientName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final int equipmentCount;

  ProjectModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.clientName,
    required this.status,
    this.startDate,
    this.endDate,
    this.location,
    this.notes,
    required this.createdAt,
    this.equipmentCount = 0,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        companyId: json['company_id'] as String,
        name: json['name'] as String,
        clientName: json['client_name'] as String?,
        status: json['status'] as String? ?? 'active',
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'client_name': clientName,
        'status': status,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'location': location,
        'notes': notes,
      };

  ProjectModel copyWith({String? status, int? equipmentCount}) => ProjectModel(
        id: id,
        companyId: companyId,
        name: name,
        clientName: clientName,
        status: status ?? this.status,
        startDate: startDate,
        endDate: endDate,
        location: location,
        notes: notes,
        createdAt: createdAt,
        equipmentCount: equipmentCount ?? this.equipmentCount,
      );

  bool get isActive => status == 'active';
}
