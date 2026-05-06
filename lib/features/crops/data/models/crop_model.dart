import '../../domain/entities/crop_entity.dart';

class CropModel extends CropEntity {
  const CropModel({
    required super.id,
    required super.plotId,
    required super.cropType,
    super.variety,
    required super.plantedAt,
    super.estimatedHarvest,
    super.harvestedAt,
    required super.status,
    super.yieldKg,
    super.notes,
    required super.createdAt,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) => CropModel(
        id: json['id'],
        plotId: json['plotId'],
        cropType: json['cropType'],
        variety: json['variety'],
        plantedAt: DateTime.parse(json['plantedAt']),
        estimatedHarvest: json['estimatedHarvest'] != null
            ? DateTime.parse(json['estimatedHarvest'])
            : null,
        harvestedAt: json['harvestedAt'] != null
            ? DateTime.parse(json['harvestedAt'])
            : null,
        status: json['status'],
        yieldKg: (json['yieldKg'] as num?)?.toDouble(),
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
