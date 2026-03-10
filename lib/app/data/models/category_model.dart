class CategoryModel {
  final String id;
  final String companyId;
  final String name;
  final String icon;
  final String color;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        companyId: json['company_id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'category',
        color: json['color'] as String? ?? '#6B7280',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'icon': icon,
        'color': color,
        'created_at': createdAt.toIso8601String(),
      };
}
