class ProjectModel {
  final String id;
  final String organisationId;
  final String name;
  final String? location;
  final String? icon;
  final String? description;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String status;
  final DateTime createdAt;

  // Joined fields
  final int itemCount;

  ProjectModel({
    required this.id,
    required this.organisationId,
    required this.name,
    this.location,
    this.icon,
    this.description,
    this.startDate,
    this.dueDate,
    required this.status,
    required this.createdAt,
    this.itemCount = 0,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // items(count) returns [{count: N}]
    int count = 0;
    final items = json['items'];
    if (items is List && items.isNotEmpty && items.first is Map) {
      count = (items.first as Map)['count'] as int? ?? 0;
    }
    return ProjectModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      itemCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'name': name,
        'location': location,
        'icon': icon,
        'description': description,
        'start_date': startDate?.toIso8601String().split('T').first,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  ProjectModel copyWith({
    String? name,
    String? location,
    String? icon,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String? status,
    int? itemCount,
  }) =>
      ProjectModel(
        id: id,
        organisationId: organisationId,
        name: name ?? this.name,
        location: location ?? this.location,
        icon: icon ?? this.icon,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        createdAt: createdAt,
        itemCount: itemCount ?? this.itemCount,
      );

  bool get isActive => status == 'active';
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && isActive;
}
