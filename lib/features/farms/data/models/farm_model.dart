import '../../domain/entities/farm_entity.dart';

class FarmModel extends FarmEntity {
  const FarmModel({
    required super.id,
    required super.name,
    super.description,
    super.lat,
    super.lng,
    super.areaHa,
    super.country,
    super.region,
    required super.isActive,
    required super.createdAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        areaHa: (json['areaHa'] as num?)?.toDouble(),
        country: json['country'],
        region: json['region'],
        isActive: json['isActive'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'lat': lat,
        'lng': lng,
        'areaHa': areaHa,
        'country': country,
        'region': region,
      };
}
