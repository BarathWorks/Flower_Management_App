import '../../domain/entities/flower.dart';

class FlowerModel extends Flower {
  const FlowerModel({
    required super.id,
    required super.name,
    super.defaultRate,
    required super.createdAt,
  });

  factory FlowerModel.fromJson(Map<String, dynamic> json) {
    return FlowerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultRate: json['default_rate'] != null
          ? (json['default_rate'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_rate': defaultRate,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
