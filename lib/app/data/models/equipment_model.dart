class EquipmentModel {
  final String id;
  final String companyId;
  final String? categoryId;
  final String name;
  final String? barcode;
  final String? serialNumber;
  final String status;
  final String condition;
  final String? imageUrl;
  final String? notes;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? categoryName;
  final String? assignedToName;
  final String? projectName;

  EquipmentModel({
    required this.id,
    required this.companyId,
    this.categoryId,
    required this.name,
    this.barcode,
    this.serialNumber,
    required this.status,
    required this.condition,
    this.imageUrl,
    this.notes,
    this.purchaseDate,
    this.purchasePrice,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.assignedToName,
    this.projectName,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    final category = json['categories'];
    return EquipmentModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      serialNumber: json['serial_number'] as String?,
      status: json['status'] as String? ?? 'in-storage',
      condition: json['condition'] as String? ?? 'good',
      imageUrl: json['image_url'] as String?,
      notes: json['notes'] as String?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryName:
          category is Map<String, dynamic> ? category['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'category_id': categoryId,
        'name': name,
        'barcode': barcode,
        'serial_number': serialNumber,
        'status': status,
        'condition': condition,
        'image_url': imageUrl,
        'notes': notes,
        'purchase_date': purchaseDate?.toIso8601String(),
        'purchase_price': purchasePrice,
      };

  EquipmentModel copyWith({
    String? status,
    String? condition,
    String? assignedToName,
    String? projectName,
  }) =>
      EquipmentModel(
        id: id,
        companyId: companyId,
        categoryId: categoryId,
        name: name,
        barcode: barcode,
        serialNumber: serialNumber,
        status: status ?? this.status,
        condition: condition ?? this.condition,
        imageUrl: imageUrl,
        notes: notes,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
        categoryName: categoryName,
        assignedToName: assignedToName ?? this.assignedToName,
        projectName: projectName ?? this.projectName,
      );

  bool get isAvailable => status == 'in-storage';
  bool get isCheckedOut => status == 'checked-out';
  bool get isInMaintenance => status == 'maintenance';
}
