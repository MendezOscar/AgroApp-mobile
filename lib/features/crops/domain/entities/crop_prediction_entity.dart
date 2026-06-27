class CropPredictionEntity {
  final double? predictedYieldKg;
  final String? yieldBasis;
  final DateTime? predictedHarvestDate;
  final String? harvestBasis;

  const CropPredictionEntity({
    this.predictedYieldKg,
    this.yieldBasis,
    this.predictedHarvestDate,
    this.harvestBasis,
  });
}
