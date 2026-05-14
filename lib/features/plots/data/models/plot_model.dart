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
        id: json['id'] as String,
        farmId: json['farmId'] as String,
        name: json['name'] as String,
        soilType: json['soilType'] as String?,
        areaHa: (json['areaHa'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'soilType': soilType,
        'areaHa': areaHa,
        'notes': notes,
      };
}
