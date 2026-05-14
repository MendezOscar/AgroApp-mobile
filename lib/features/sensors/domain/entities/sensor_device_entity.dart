class SensorDeviceEntity {
  final String id;
  final String plotId;
  final String deviceCode;
  final String deviceType;
  final double? lat;
  final double? lng;
  final int? batteryPct;
  final String? firmwareVer; // ← agregar
  final bool isActive;
  final DateTime? lastSeenAt;

  const SensorDeviceEntity({
    required this.id,
    required this.plotId,
    required this.deviceCode,
    required this.deviceType,
    this.lat,
    this.lng,
    this.batteryPct,
    this.firmwareVer,
    required this.isActive,
    this.lastSeenAt,
  });
}
