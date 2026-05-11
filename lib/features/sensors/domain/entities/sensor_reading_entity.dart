class SensorReadingEntity {
  final String id;
  final String deviceId;
  final double? temperature;
  final double? humidityAir;
  final double? humiditySoil;
  final double? luminosity;
  final double? rainMm;
  final double? ph;
  final double? ec;
  final DateTime recordedAt;

  const SensorReadingEntity({
    required this.id,
    required this.deviceId,
    this.temperature,
    this.humidityAir,
    this.humiditySoil,
    this.luminosity,
    this.rainMm,
    this.ph,
    this.ec,
    required this.recordedAt,
  });
}
