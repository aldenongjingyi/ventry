class ItemGroupModel {
  final String id;
  final String organisationId;
  final String name;
  final DateTime createdAt;

  ItemGroupModel({
    required this.id,
    required this.organisationId,
    required this.name,
    required this.createdAt,
  });

  factory ItemGroupModel.fromJson(Map<String, dynamic> json) {
    return ItemGroupModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };
}
