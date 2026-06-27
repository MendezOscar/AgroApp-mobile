import '../../domain/entities/crop_comparison_entity.dart';

class CropComparisonModel extends CropComparisonEntity {
  const CropComparisonModel({
    required super.id,
    required super.cropType,
    super.variety,
    required super.plotName,
    required super.status,
    super.yieldKg,
    required super.totalCost,
  });

  factory CropComparisonModel.fromJson(Map<String, dynamic> json) {
    return CropComparisonModel(
      id: json['id'],
      cropType: json['cropType'],
      variety: json['variety'],
      plotName: json['plotName'],
      status: json['status'],
      yieldKg: (json['yieldKg'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }
}
