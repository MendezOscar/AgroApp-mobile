import '../../domain/entities/sensor_reading_entity.dart';

class SensorReadingModel extends SensorReadingEntity {
  const SensorReadingModel({
    required super.id,
    required super.deviceId,
    super.temperature,
    super.humidityAir,
    super.humiditySoil,
    super.luminosity,
    super.rainMm,
    super.ph,
    super.ec,
    required super.recordedAt,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) =>
      SensorReadingModel(
        id: json['id'],
        deviceId: json['deviceId'],
        temperature: (json['temperature'] as num?)?.toDouble(),
        humidityAir: (json['humidityAir'] as num?)?.toDouble(),
        humiditySoil: (json['humiditySoil'] as num?)?.toDouble(),
        luminosity: (json['luminosity'] as num?)?.toDouble(),
        rainMm: (json['rainMm'] as num?)?.toDouble(),
        ph: (json['ph'] as num?)?.toDouble(),
        ec: (json['ec'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(json['recordedAt']),
      );
}
