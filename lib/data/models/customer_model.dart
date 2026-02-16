import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    super.phone,
    super.address,
    super.defaultCommission,
    required super.createdAt,
    super.flowerIds,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      defaultCommission: json['default_commission'] != null
          ? (json['default_commission'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      flowerIds: json['flower_ids'] != null
          ? List<String>.from(json['flower_ids'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'default_commission': defaultCommission,
      'created_at': createdAt.toIso8601String(),
      'flower_ids': flowerIds,
    };
  }
}
