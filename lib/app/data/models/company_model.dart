class CompanyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
      };

  CompanyModel copyWith({String? name}) => CompanyModel(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
      );
}
