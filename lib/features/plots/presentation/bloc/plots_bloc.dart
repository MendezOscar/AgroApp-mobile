import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/plots_repository.dart';
import 'plots_event.dart';
import 'plots_state.dart';

class PlotsBloc extends Bloc<PlotsEvent, PlotsState> {
  final PlotsRepository _repository;

  PlotsBloc(this._repository) : super(PlotsInitial()) {
    on<LoadPlots>(_onLoadPlots);
    on<CreatePlot>(_onCreatePlot);
    on<DeletePlot>(_onDeletePlot);
  }

  Future<void> _onLoadPlots(LoadPlots event, Emitter<PlotsState> emit) async {
    emit(PlotsLoading());
    try {
      final plots = await _repository.getPlots(event.farmId);
      emit(PlotsLoaded(plots));
    } catch (e) {
      emit(PlotsError('Error al cargar las parcelas.'));
    }
  }

  Future<void> _onCreatePlot(CreatePlot event, Emitter<PlotsState> emit) async {
    try {
      await _repository.createPlot(event.farmId, {
        'name': event.name,
        'soilType': event.soilType,
        'areaHa': event.areaHa,
        'notes': event.notes,
      });
      add(LoadPlots(event.farmId));
    } catch (e) {
      emit(PlotsError('Error al crear la parcela.'));
    }
  }

  Future<void> _onDeletePlot(DeletePlot event, Emitter<PlotsState> emit) async {
    try {
      await _repository.deletePlot(event.farmId, event.plotId);
      add(LoadPlots(event.farmId));
    } catch (e) {
      emit(PlotsError('Error al eliminar la parcela.'));
    }
  }
}
