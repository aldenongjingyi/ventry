class OrganisationModel {
  final String id;
  final String name;
  final String plan;
  final DateTime createdAt;

  OrganisationModel({
    required this.id,
    required this.name,
    required this.plan,
    required this.createdAt,
  });

  factory OrganisationModel.fromJson(Map<String, dynamic> json) =>
      OrganisationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        plan: json['plan'] as String? ?? 'free',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan': plan,
        'created_at': createdAt.toIso8601String(),
      };

  OrganisationModel copyWith({String? name, String? plan}) =>
      OrganisationModel(
        id: id,
        name: name ?? this.name,
        plan: plan ?? this.plan,
        createdAt: createdAt,
      );

  bool get isFree => plan == 'free';
  bool get isPro => plan == 'pro';

  String get displayPlan {
    switch (plan) {
      case 'free': return 'Free';
      case 'pro': return 'Pro';
      default: return plan;
    }
  }
}
