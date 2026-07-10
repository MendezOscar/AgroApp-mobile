import '../../domain/entities/crop_sale_entity.dart';

class CropSaleModel extends CropSaleEntity {
  const CropSaleModel({
    required super.id,
    required super.cropId,
    required super.soldAt,
    required super.quantityKg,
    required super.pricePerKg,
    required super.totalAmount,
    super.buyer,
    super.notes,
    required super.createdAt,
  });

  factory CropSaleModel.fromJson(Map<String, dynamic> json) => CropSaleModel(
        id: json['id'],
        cropId: json['cropId'],
        soldAt: DateTime.parse(json['soldAt']),
        quantityKg: (json['quantityKg'] as num).toDouble(),
        pricePerKg: (json['pricePerKg'] as num).toDouble(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        buyer: json['buyer'],
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
