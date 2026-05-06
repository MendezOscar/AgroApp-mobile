class CropEntity {
  final String id;
  final String plotId;
  final String cropType;
  final String? variety;
  final DateTime plantedAt;
  final DateTime? estimatedHarvest;
  final DateTime? harvestedAt;
  final String status;
  final double? yieldKg;
  final String? notes;
  final DateTime createdAt;

  const CropEntity({
    required this.id,
    required this.plotId,
    required this.cropType,
    this.variety,
    required this.plantedAt,
    this.estimatedHarvest,
    this.harvestedAt,
    required this.status,
    this.yieldKg,
    this.notes,
    required this.createdAt,
  });
}
