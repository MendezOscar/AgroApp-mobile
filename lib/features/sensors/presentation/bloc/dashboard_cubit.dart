import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../alerts/data/datasources/alerts_remote_datasource.dart';
import '../../../farms/data/datasources/farms_remote_datasource.dart';
import '../../../plots/data/datasources/plots_remote_datasource.dart';
import '../../../crops/data/datasources/crops_remote_datasource.dart';
import '../../../sensors/data/datasources/sensors_remote_datasource.dart';
import '../../../sensors/data/models/sensor_device_model.dart';
import '../../../sensors/data/models/sensor_reading_model.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final FarmsRemoteDatasource _farmsDs;
  final PlotsRemoteDatasource _plotsDs;
  final CropsRemoteDatasource _cropsDs;
  final SensorsRemoteDatasource _sensorsDs;
  final AlertsRemoteDatasource _alertsDs;

  DashboardCubit({
    required FarmsRemoteDatasource farmsDs,
    required PlotsRemoteDatasource plotsDs,
    required CropsRemoteDatasource cropsDs,
    required SensorsRemoteDatasource sensorsDs,
    required AlertsRemoteDatasource alertsDs,
  })  : _farmsDs = farmsDs,
        _plotsDs = plotsDs,
        _cropsDs = cropsDs,
        _sensorsDs = sensorsDs,
        _alertsDs = alertsDs,
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

      emit(state.copyWith(
        isLoading: false,
        latestReading: latestReading,
        readings: readings,
        activeCrops: activeCrops,
        unreadAlerts: unreadCount,
      ));
    } catch (e) {
      print('ERROR DASHBOARD: $e');
      emit(
          state.copyWith(isLoading: false, error: 'Error al cargar dashboard'));
    }
  }
}
