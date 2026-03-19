class ProjectModel {
  final String id;
  final String organisationId;
  final String name;
  final String? location;
  final String status;
  final DateTime createdAt;

  // Joined fields
  final int itemCount;

  ProjectModel({
    required this.id,
    required this.organisationId,
    required this.name,
    this.location,
    required this.status,
    required this.createdAt,
    this.itemCount = 0,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        organisationId: json['organisation_id'] as String,
        name: json['name'] as String,
        location: json['location'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'name': name,
        'location': location,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  ProjectModel copyWith({
    String? name,
    String? location,
    String? status,
    int? itemCount,
  }) =>
      ProjectModel(
        id: id,
        organisationId: organisationId,
        name: name ?? this.name,
        location: location ?? this.location,
        status: status ?? this.status,
        createdAt: createdAt,
        itemCount: itemCount ?? this.itemCount,
      );

  bool get isActive => status == 'active';
}
