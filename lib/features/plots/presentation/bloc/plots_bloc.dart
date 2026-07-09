import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/geo_point.dart';
import '../../data/repositories/plots_local_repository.dart';
import '../../domain/entities/plot_entity.dart';
import '../../domain/repositories/plots_repository.dart';
import 'plots_event.dart';
import 'plots_state.dart';

class PlotsBloc extends Bloc<PlotsEvent, PlotsState> {
  final PlotsRepository _repository;
  final PlotsLocalRepository _localRepository;

  PlotsBloc(this._repository, this._localRepository) : super(PlotsInitial()) {
    on<LoadPlots>(_onLoadPlots);
    on<CreatePlot>(_onCreatePlot);
    on<UpdatePlotShape>(_onUpdatePlotShape);
    on<DeletePlot>(_onDeletePlot);
  }

  Future<void> _onLoadPlots(LoadPlots event, Emitter<PlotsState> emit) async {
    emit(PlotsLoading());
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final plots = await _repository.getPlots(event.farmId);
        await _localRepository.savePlots(event.farmId, plots);
        emit(PlotsLoaded(plots, isOffline: false));
      } else {
        final plots = await _localRepository.getPlots(event.farmId);
        emit(PlotsLoaded(plots, isOffline: true));
      }
    } catch (e) {
      try {
        final plots =
            await _localRepository.getPlots((event as LoadPlots).farmId);
        emit(PlotsLoaded(plots, isOffline: true));
      } catch (_) {
        emit(PlotsError('Error al cargar las parcelas.'));
      }
    }
  }

  Future<void> _onCreatePlot(CreatePlot event, Emitter<PlotsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      final data = {
        'name': event.name,
        'soilType': event.soilType,
        'areaHa': event.areaHa,
        'notes': event.notes,
      };
      if (isOnline) {
        await _repository.createPlot(event.farmId, data);
      } else {
        await _localRepository.savePendingCreate(event.farmId, data);
      }
      add(LoadPlots(event.farmId));
    } catch (e) {
      debugPrint('PlotsBloc._onCreatePlot error: $e');
      final previous = state;
      emit(PlotsError('Error al crear la parcela.'));
      if (previous is PlotsLoaded) emit(previous);
    }
  }

  Future<void> _onUpdatePlotShape(
      UpdatePlotShape event, Emitter<PlotsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        final previous = state;
        emit(PlotsError(
            'Sin conexión. No se puede actualizar la ubicación ahora.'));
        if (previous is PlotsLoaded) emit(previous);
        return;
      }
      PlotEntity? current;
      if (state is PlotsLoaded) {
        for (final p in (state as PlotsLoaded).plots) {
          if (p.id == event.plotId) {
            current = p;
            break;
          }
        }
      }

      await _repository.updatePlot(event.farmId, event.plotId, {
        'name': current?.name,
        'soilType': current?.soilType,
        'notes': current?.notes,
        'areaHa': polygonAreaHectares(event.points),
        'geoJson': encodeGeoPolygon(event.points),
      });
      add(LoadPlots(event.farmId));
    } catch (e) {
      if (e is DioException) {
        debugPrint('PlotsBloc._onUpdatePlotShape: '
            '${e.response?.statusCode} ${e.response?.data}');
      } else {
        debugPrint('PlotsBloc._onUpdatePlotShape error: $e');
      }
      final previous = state;
      emit(PlotsError('Error al actualizar la ubicación.'));
      if (previous is PlotsLoaded) emit(previous);
    }
  }

  Future<void> _onDeletePlot(DeletePlot event, Emitter<PlotsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _repository.deletePlot(event.farmId, event.plotId);
        add(LoadPlots(event.farmId));
      } else {
        final previous = state;
        emit(PlotsError('Sin conexión. No se puede eliminar ahora.'));
        if (previous is PlotsLoaded) emit(previous);
      }
    } catch (e) {
      debugPrint('PlotsBloc._onDeletePlot error: $e');
      final previous = state;
      emit(PlotsError('Error al eliminar la parcela.'));
      if (previous is PlotsLoaded) emit(previous);
    }
  }
}
