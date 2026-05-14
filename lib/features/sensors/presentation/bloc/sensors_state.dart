import 'package:equatable/equatable.dart';
import '../../domain/entities/sensor_device_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';

class SensorsState extends Equatable {
  final List<SensorDeviceEntity> devices;
  final SensorReadingEntity? latestReading;
  final List<SensorReadingEntity> readings;
  final bool isLoadingDevices;
  final bool isLoadingReadings;
  final bool isSendingReading;
  final String? error;
  final String? success;

  const SensorsState({
    this.devices = const [],
    this.latestReading,
    this.readings = const [],
    this.isLoadingDevices = false,
    this.isLoadingReadings = false,
    this.isSendingReading = false,
    this.error,
    this.success,
  });

  SensorsState copyWith({
    List<SensorDeviceEntity>? devices,
    SensorReadingEntity? latestReading,
    List<SensorReadingEntity>? readings,
    bool? isLoadingDevices,
    bool? isLoadingReadings,
    bool? isSendingReading,
    String? error,
    String? success,
  }) =>
      SensorsState(
        devices: devices ?? this.devices,
        latestReading: latestReading ?? this.latestReading,
        readings: readings ?? this.readings,
        isLoadingDevices: isLoadingDevices ?? this.isLoadingDevices,
        isLoadingReadings: isLoadingReadings ?? this.isLoadingReadings,
        isSendingReading: isSendingReading ?? this.isSendingReading,
        error: error,
        success: success,
      );

  @override
  List<Object?> get props => [
        devices,
        latestReading,
        readings,
        isLoadingDevices,
        isLoadingReadings,
        isSendingReading,
        error,
        success,
      ];
}
