import '../../../../core/bloc/safe_cubit.dart';
import '../../../alerts/data/datasources/alerts_remote_datasource.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../../plots/data/datasources/plots_remote_datasource.dart';
import '../../../crops/data/datasources/crops_remote_datasource.dart';
import '../../../costs/data/datasources/costs_remote_datasource.dart';
import '../../../costs/data/models/monthly_cost_model.dart';
import '../../../costs/domain/entities/monthly_cost_entity.dart';
import '../../../sensors/data/datasources/sensors_remote_datasource.dart';
import '../../../sensors/data/models/sensor_device_model.dart';
import '../../../sensors/data/models/sensor_reading_model.dart';
import '../../../weather/data/datasources/weather_remote_datasource.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import 'dashboard_state.dart';

class DashboardCubit extends SafeCubit<DashboardState> {
  final FarmsRemoteDatasource _farmsDs;
  final PlotsRemoteDatasource _plotsDs;
  final CropsRemoteDatasource _cropsDs;
  final SensorsRemoteDatasource _sensorsDs;
  final AlertsRemoteDatasource _alertsDs;
  final WeatherRemoteDatasource _weatherDs;
  final CostsRemoteDatasource _costsDs;

  DashboardCubit({
    required FarmsRemoteDatasource farmsDs,
    required PlotsRemoteDatasource plotsDs,
    required CropsRemoteDatasource cropsDs,
    required SensorsRemoteDatasource sensorsDs,
    required AlertsRemoteDatasource alertsDs,
    required WeatherRemoteDatasource weatherDs,
    required CostsRemoteDatasource costsDs,
  })  : _farmsDs = farmsDs,
        _plotsDs = plotsDs,
        _cropsDs = cropsDs,
        _sensorsDs = sensorsDs,
        _alertsDs = alertsDs,
        _weatherDs = weatherDs,
        _costsDs = costsDs,
        super(const DashboardState());

  Future<void> loadDashboard() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    try {
      // Cargar fincas
      final farms = await _farmsDs.getFarms();
      if (isClosed) return;
      if (farms.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Contar cultivos activos y buscar sensores
      int activeCrops = 0;
      String? firstDeviceId;

      for (final farm in farms) {
        if (isClosed) return;
        final plots = await _plotsDs.getPlots(farm['id']);
        for (final plot in plots) {
          if (isClosed) return;
          // Cultivos activos
          final crops = await _cropsDs.getCrops(plot['id']);
          activeCrops += crops.where((c) => c['status'] == 'Active').length;

          // Buscar primer sensor disponible
          if (firstDeviceId == null) {
            try {
              final sensors = await _sensorsDs.getSensorDevices(plot['id']);
              if (sensors.isNotEmpty) {
                firstDeviceId = sensors.first['id'];
                emit(state.copyWith(
                  devices: sensors
                      .map((s) => SensorDeviceModel.fromJson(s))
                      .toList(),
                ));
              }
            } catch (_) {}
          }
        }
      }

      if (isClosed) return;

      // Cargar lecturas del primer sensor
      SensorReadingEntity? latestReading;
      List<SensorReadingEntity> readings = [];

      if (firstDeviceId != null) {
        final latestData = await _sensorsDs.getLatestReading(firstDeviceId);
        if (latestData != null) {
          latestReading = SensorReadingModel.fromJson(latestData);
        }

        final readingsData =
            await _sensorsDs.getSensorReadings(firstDeviceId, limit: 30);
        readings =
            readingsData.map((r) => SensorReadingModel.fromJson(r)).toList();
      }

      if (isClosed) return;

      // Alertas sin leer
      final unreadCount = await _alertsDs.getUnreadCount();

      // Clima de la finca (si tiene coordenadas)
      final lat = (farms.first['lat'] as num?)?.toDouble();
      final lng = (farms.first['lng'] as num?)?.toDouble();
      final weather = lat != null && lng != null
          ? await _weatherDs.getCurrentWeather(lat, lng)
          : null;

      if (isClosed) return;

      // Historial de gastos mensuales
      List<MonthlyCostEntity> costHistory = [];
      try {
        final costData = await _costsDs.getMonthlyCostHistory(months: 6);
        costHistory =
            costData.map((c) => MonthlyCostModel.fromJson(c)).toList();
      } catch (_) {}

      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        latestReading: latestReading,
        readings: readings,
        activeCrops: activeCrops,
        unreadAlerts: unreadCount,
        weather: weather,
        costHistory: costHistory,
      ));
    } catch (e) {
      print('ERROR DASHBOARD: $e');
      emit(
          state.copyWith(isLoading: false, error: 'Error al cargar dashboard'));
    }
  }
}
