class CropComparisonEntity {
  final String id;
  final String cropType;
  final String? variety;
  final String plotName;
  final String status;
  final double? yieldKg;
  final double totalCost;

  const CropComparisonEntity({
    required this.id,
    required this.cropType,
    this.variety,
    required this.plotName,
    required this.status,
    this.yieldKg,
    required this.totalCost,
  });
}
