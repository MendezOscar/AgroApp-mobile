import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/sensors_remote_datasource.dart';
import '../../data/models/sensor_device_model.dart';
import '../../data/models/sensor_reading_model.dart';
import 'sensors_state.dart';

class SensorsCubit extends Cubit<SensorsState> {
  final SensorsRemoteDatasource _datasource;

  SensorsCubit(this._datasource) : super(const SensorsState());

  Future<void> loadDevices(String plotId) async {
    emit(state.copyWith(isLoadingDevices: true, error: null));
    try {
      final data = await _datasource.getSensorDevices(plotId);
      emit(state.copyWith(
        devices: data.map((e) => SensorDeviceModel.fromJson(e)).toList(),
        isLoadingDevices: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingDevices: false, error: 'Error al cargar sensores'));
    }
  }

  Future<void> createDevice(String plotId, Map<String, dynamic> data) async {
    try {
      await _datasource.createSensorDevice(plotId, data);
      await loadDevices(plotId);
      emit(state.copyWith(success: 'Sensor registrado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al registrar sensor'));
    }
  }

  Future<void> loadReadings(String deviceId, {int limit = 30}) async {
    emit(state.copyWith(isLoadingReadings: true, error: null));
    try {
      final latestData = await _datasource.getLatestReading(deviceId);
      final readingsData =
          await _datasource.getSensorReadings(deviceId, limit: limit);

      emit(state.copyWith(
        latestReading:
            latestData != null ? SensorReadingModel.fromJson(latestData) : null,
        readings:
            readingsData.map((e) => SensorReadingModel.fromJson(e)).toList(),
        isLoadingReadings: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoadingReadings: false, error: 'Error al cargar lecturas'));
    }
  }

  Future<void> sendTestReading(
      String deviceId, Map<String, dynamic> data) async {
    emit(state.copyWith(isSendingReading: true, error: null));
    try {
      await _datasource.sendReading(deviceId, data);
      await loadReadings(deviceId);
      emit(state.copyWith(
          isSendingReading: false, success: 'Lectura enviada correctamente'));
    } catch (e) {
      emit(state.copyWith(
          isSendingReading: false, error: 'Error al enviar lectura'));
    }
  }
}
