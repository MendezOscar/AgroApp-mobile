import 'package:flutter/material.dart';
import '../../features/crops/data/datasources/crops_remote_datasource.dart';
import '../../features/crops/data/repositories/crops_local_repository.dart';
import '../../features/crops/data/models/crop_model.dart';
import '../../features/farms/data/datasources/farms_remote_datasource.dart';
import '../../features/farms/data/repositories/farms_local_repository.dart';
import '../../features/farms/data/models/farm_model.dart';
import '../../features/plots/data/datasources/plots_remote_datasource.dart';
import '../../features/plots/data/repositories/plots_local_repository.dart';
import '../../features/plots/data/models/plot_model.dart';
import '../../features/alerts/data/datasources/alerts_remote_datasource.dart';
import '../../features/alerts/data/repositories/alerts_local_repository.dart';
import '../../features/alerts/data/models/alert_model.dart';
import '../../features/shifts/data/datasources/shifts_remote_datasource.dart';
import '../../features/shifts/data/models/task_occurrence_model.dart';
import '../../features/shifts/data/repositories/shifts_local_repository.dart';
import '../../features/task/data/datasources/tasks_remote_datasource.dart';
import '../../features/task/data/models/task_model.dart';
import '../../features/task/data/repositories/tasks_local_repository.dart';
import '../models/paged_result.dart';
import 'connectivity_service.dart';

class InitialSyncService {
  final FarmsRemoteDatasource _farmsDs;
  final PlotsRemoteDatasource _plotsDs;
  final CropsRemoteDatasource _cropsDs;
  final AlertsRemoteDatasource _alertsDs;
  final TasksRemoteDatasource _tasksDs;
  final ShiftsRemoteDatasource _shiftsDs;
  final TasksLocalRepository _tasksLocal;
  final ShiftsLocalRepository _shiftsLocal;
  final FarmsLocalRepository _farmsLocal;
  final PlotsLocalRepository _plotsLocal;
  final CropsLocalRepository _cropsLocal;
  final AlertsLocalRepository _alertsLocal;

  InitialSyncService({
    required FarmsRemoteDatasource farmsDs,
    required PlotsRemoteDatasource plotsDs,
    required CropsRemoteDatasource cropsDs,
    required AlertsRemoteDatasource alertsDs,
    required FarmsLocalRepository farmsLocal,
    required PlotsLocalRepository plotsLocal,
    required CropsLocalRepository cropsLocal,
    required AlertsLocalRepository alertsLocal,
    required TasksRemoteDatasource tasksDs,
    required ShiftsRemoteDatasource shiftsDs,
    required TasksLocalRepository tasksLocal,
    required ShiftsLocalRepository shiftsLocal,
  })  : _farmsDs = farmsDs,
        _plotsDs = plotsDs,
        _cropsDs = cropsDs,
        _alertsDs = alertsDs,
        _farmsLocal = farmsLocal,
        _plotsLocal = plotsLocal,
        _cropsLocal = cropsLocal,
        _alertsLocal = alertsLocal,
        _tasksDs = tasksDs,
        _shiftsDs = shiftsDs,
        _tasksLocal = tasksLocal,
        _shiftsLocal = shiftsLocal;

  /// Descarga toda la jerarquía y la guarda en SQLite
  Future<void> syncAll() async {
    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      debugPrint('InitialSync: sin conexión, omitiendo sync');
      return;
    }

    debugPrint('InitialSync: iniciando sincronización completa...');

    try {
      // 1. Sincronizar fincas
      final farmsData = await _farmsDs.getFarms();
      final farms = farmsData.map((e) => FarmModel.fromJson(e)).toList();
      await _farmsLocal.saveFarms(farms);
      debugPrint('InitialSync: ${farms.length} fincas guardadas');

      // 2. Sincronizar parcelas de cada finca
      for (final farm in farmsData) {
        final farmId = farm['id'] as String;
        try {
          final plotsData = await _plotsDs.getPlots(farmId);
          final plots = plotsData.map((e) => PlotModel.fromJson(e)).toList();
          await _plotsLocal.savePlots(farmId, plots);
          debugPrint(
              'InitialSync: ${plots.length} parcelas guardadas para finca $farmId');

          // 3. Sincronizar cultivos de cada parcela
          for (final plot in plotsData) {
            final plotId = plot['id'] as String;
            try {
              final cropsData = await _cropsDs.getCrops(plotId);
              final crops =
                  cropsData.map((e) => CropModel.fromJson(e)).toList();
              await _cropsLocal.saveCrops(plotId, crops);
              debugPrint(
                  'InitialSync: ${crops.length} cultivos guardados para parcela $plotId');
            } catch (e) {
              debugPrint('InitialSync: error en cultivos de $plotId: $e');
            }
          }
        } catch (e) {
          debugPrint('InitialSync: error en parcelas de $farmId: $e');
        }
      }

      // 4. Sincronizar alertas
      try {
        final raw = await _alertsDs.getAlerts(pageSize: 100);
        final paged = PagedResult.fromJson(raw, AlertModel.fromJson);
        await _alertsLocal.saveAlerts(paged.items);
        debugPrint('InitialSync: ${paged.items.length} alertas guardadas');
      } catch (e) {
        debugPrint('InitialSync: error en alertas: $e');
      }

      try {
        final raw = await _tasksDs.getTasks(onlyMine: false, pageSize: 100);
        final paged = PagedResult.fromJson(raw, TaskModel.fromJson);
        await _tasksLocal.saveTasks(paged.items);
        debugPrint('InitialSync: ${paged.items.length} tareas guardadas');
      } catch (e) {
        debugPrint('InitialSync: error en tareas: $e');
      }

// 6. Sincronizar turnos de los próximos 7 días
      try {
        final occurrencesData = await _shiftsDs.getOccurrences();
        final occurrences = occurrencesData
            .map((e) => TaskOccurrenceModel.fromJson(e))
            .toList();
        await _shiftsLocal.saveOccurrences(occurrences);
        debugPrint('InitialSync: ${occurrences.length} turnos guardados');
      } catch (e) {
        debugPrint('InitialSync: error en turnos: $e');
      }

      debugPrint('InitialSync: sincronización completa ✅');
    } catch (e) {
      debugPrint('InitialSync: error general: $e');
    }
  }
}
