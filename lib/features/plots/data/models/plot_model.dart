import '../../domain/entities/plot_entity.dart';

class PlotModel extends PlotEntity {
  const PlotModel({
    required super.id,
    required super.farmId,
    required super.name,
    super.soilType,
    super.areaHa,
    super.notes,
    required super.isActive,
    required super.createdAt,
  });

  factory PlotModel.fromJson(Map<String, dynamic> json) => PlotModel(
        id: json['id'],
        farmId: json['farmId'],
        name: json['name'],
        soilType: json['soilType'],
        areaHa: (json['areaHa'] as num?)?.toDouble(),
        notes: json['notes'],
        isActive: json['isActive'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'soilType': soilType,
        'areaHa': areaHa,
        'notes': notes,
      };
}
