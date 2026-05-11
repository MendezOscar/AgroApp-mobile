import '../../domain/entities/sensor_device_entity.dart';

class SensorDeviceModel extends SensorDeviceEntity {
  const SensorDeviceModel({
    required super.id,
    required super.plotId,
    required super.deviceCode,
    required super.deviceType,
    super.lat,
    super.lng,
    super.batteryPct,
    required super.isActive,
    super.lastSeenAt,
  });

  factory SensorDeviceModel.fromJson(Map<String, dynamic> json) =>
      SensorDeviceModel(
        id: json['id'],
        plotId: json['plotId'],
        deviceCode: json['deviceCode'],
        deviceType: json['deviceType'],
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        batteryPct: json['batteryPct'],
        isActive: json['isActive'],
        lastSeenAt: json['lastSeenAt'] != null
            ? DateTime.parse(json['lastSeenAt'])
            : null,
      );
}
