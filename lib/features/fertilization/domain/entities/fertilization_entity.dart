class FertilizationEntity {
  final String id;
  final String cropId;
  final String productName;
  final String? productType;
  final double? doseKgHa;
  final double? totalKg;
  final String? method;
  final double? cost;
  final DateTime appliedAt;
  final DateTime? nextApplication;
  final String? notes;
  final DateTime createdAt;

  const FertilizationEntity({
    required this.id,
    required this.cropId,
    required this.productName,
    this.productType,
    this.doseKgHa,
    this.totalKg,
    this.method,
    this.cost,
    required this.appliedAt,
    this.nextApplication,
    this.notes,
    required this.createdAt,
  });
}
