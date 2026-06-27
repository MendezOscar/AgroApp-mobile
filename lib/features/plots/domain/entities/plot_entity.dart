class PlotEntity {
  final String id;
  final String farmId;
  final String name;
  final String? soilType;
  final double? areaHa;
  final String? notes;
  final String? geoJson;
  final bool isActive;
  final DateTime createdAt;

  const PlotEntity({
    required this.id,
    required this.farmId,
    required this.name,
    this.soilType,
    this.areaHa,
    this.notes,
    this.geoJson,
    required this.isActive,
    required this.createdAt,
  });
}
