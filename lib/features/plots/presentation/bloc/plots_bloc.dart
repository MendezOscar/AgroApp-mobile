import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/repositories/plots_local_repository.dart';
import '../../domain/repositories/plots_repository.dart';
import 'plots_event.dart';
import 'plots_state.dart';

class PlotsBloc extends Bloc<PlotsEvent, PlotsState> {
  final PlotsRepository _repository;
  final PlotsLocalRepository _localRepository;

  PlotsBloc(this._repository, this._localRepository) : super(PlotsInitial()) {
    on<LoadPlots>(_onLoadPlots);
    on<CreatePlot>(_onCreatePlot);
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
      emit(PlotsError('Error al crear la parcela.'));
    }
  }

  Future<void> _onDeletePlot(DeletePlot event, Emitter<PlotsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _repository.deletePlot(event.farmId, event.plotId);
        add(LoadPlots(event.farmId));
      } else {
        emit(PlotsError('Sin conexión. No se puede eliminar ahora.'));
      }
    } catch (e) {
      emit(PlotsError('Error al eliminar la parcela.'));
    }
  }
}
