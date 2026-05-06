class FarmEntity {
  final String id;
  final String name;
  final String? description;
  final double? lat;
  final double? lng;
  final double? areaHa;
  final String? country;
  final String? region;
  final bool isActive;
  final DateTime createdAt;

  const FarmEntity({
    required this.id,
    required this.name,
    this.description,
    this.lat,
    this.lng,
    this.areaHa,
    this.country,
    this.region,
    required this.isActive,
    required this.createdAt,
  });
}
