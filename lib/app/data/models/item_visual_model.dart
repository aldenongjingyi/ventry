class ItemVisualModel {
  final String id;
  final String organisationId;
  final String itemName;
  final String visualType; // 'icon' or 'photo'
  final String visualValue; // icon name or storage path
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemVisualModel({
    required this.id,
    required this.organisationId,
    required this.itemName,
    required this.visualType,
    required this.visualValue,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIcon => visualType == 'icon';
  bool get isPhoto => visualType == 'photo';

  factory ItemVisualModel.fromJson(Map<String, dynamic> json) {
    return ItemVisualModel(
      id: json['id'] as String,
      organisationId: json['organisation_id'] as String,
      itemName: json['item_name'] as String,
      visualType: json['visual_type'] as String,
      visualValue: json['visual_value'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organisation_id': organisationId,
        'item_name': itemName,
        'visual_type': visualType,
        'visual_value': visualValue,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
