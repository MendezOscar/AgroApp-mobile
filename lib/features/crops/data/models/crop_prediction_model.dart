import '../../domain/entities/crop_prediction_entity.dart';

class CropPredictionModel extends CropPredictionEntity {
  const CropPredictionModel({
    super.predictedYieldKg,
    super.yieldBasis,
    super.predictedHarvestDate,
    super.harvestBasis,
  });

  factory CropPredictionModel.fromJson(Map<String, dynamic> json) =>
      CropPredictionModel(
        predictedYieldKg: (json['predictedYieldKg'] as num?)?.toDouble(),
        yieldBasis: json['yieldBasis'] as String?,
        predictedHarvestDate: json['predictedHarvestDate'] != null
            ? DateTime.parse(json['predictedHarvestDate'] as String)
            : null,
        harvestBasis: json['harvestBasis'] as String?,
      );
}
