import 'package:equatable/equatable.dart';
import '../../../sensors/domain/entities/sensor_reading_entity.dart';
import '../../../sensors/domain/entities/sensor_device_entity.dart';
import '../../../costs/domain/entities/monthly_cost_entity.dart';
import '../../../weather/domain/entities/weather_entity.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final SensorReadingEntity? latestReading;
  final List<SensorReadingEntity> readings;
  final List<SensorDeviceEntity> devices;
  final int activeCrops;
  final int unreadAlerts;
  final WeatherEntity? weather;
  final List<MonthlyCostEntity> costHistory;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.latestReading,
    this.readings = const [],
    this.devices = const [],
    this.activeCrops = 0,
    this.unreadAlerts = 0,
    this.weather,
    this.costHistory = const [],
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    SensorReadingEntity? latestReading,
    List<SensorReadingEntity>? readings,
    List<SensorDeviceEntity>? devices,
    int? activeCrops,
    int? unreadAlerts,
    WeatherEntity? weather,
    List<MonthlyCostEntity>? costHistory,
    String? error,
  }) =>
      DashboardState(
        isLoading: isLoading ?? this.isLoading,
        latestReading: latestReading ?? this.latestReading,
        readings: readings ?? this.readings,
        devices: devices ?? this.devices,
        activeCrops: activeCrops ?? this.activeCrops,
        unreadAlerts: unreadAlerts ?? this.unreadAlerts,
        weather: weather ?? this.weather,
        costHistory: costHistory ?? this.costHistory,
        error: error,
      );

  @override
  List<Object?> get props => [
        isLoading,
        latestReading,
        readings,
        devices,
        activeCrops,
        unreadAlerts,
        weather,
        costHistory,
        error
      ];
}
