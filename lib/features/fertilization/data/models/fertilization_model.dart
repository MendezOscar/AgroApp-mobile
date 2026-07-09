import '../../domain/entities/fertilization_entity.dart';

class FertilizationModel extends FertilizationEntity {
  const FertilizationModel({
    required super.id,
    required super.cropId,
    super.taskId,
    required super.productName,
    super.productType,
    super.doseKgHa,
    super.totalKg,
    super.method,
    super.cost,
    required super.appliedAt,
    super.nextApplication,
    super.notes,
    required super.createdAt,
  });

  factory FertilizationModel.fromJson(Map<String, dynamic> json) =>
      FertilizationModel(
        id: json['id'],
        cropId: json['cropId'],
        taskId: json['taskId'],
        productName: json['productName'],
        productType: json['productType'],
        doseKgHa: (json['doseKgHa'] as num?)?.toDouble(),
        totalKg: (json['totalKg'] as num?)?.toDouble(),
        method: json['method'],
        cost: (json['cost'] as num?)?.toDouble(),
        appliedAt: DateTime.parse(json['appliedAt']),
        nextApplication: json['nextApplication'] != null
            ? DateTime.parse(json['nextApplication'])
            : null,
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
