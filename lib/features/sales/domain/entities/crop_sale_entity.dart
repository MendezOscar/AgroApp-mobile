class CropSaleEntity {
  final String id;
  final String cropId;
  final DateTime soldAt;
  final double quantityKg;
  final double pricePerKg;
  final double totalAmount;
  final String? buyer;
  final String? notes;
  final DateTime createdAt;

  const CropSaleEntity({
    required this.id,
    required this.cropId,
    required this.soldAt,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalAmount,
    this.buyer,
    this.notes,
    required this.createdAt,
  });
}
