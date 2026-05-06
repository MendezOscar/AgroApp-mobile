import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/crops_repository.dart';
import 'crops_event.dart';
import 'crops_state.dart';

class CropsBloc extends Bloc<CropsEvent, CropsState> {
  final CropsRepository _repository;

  CropsBloc(this._repository) : super(CropsInitial()) {
    on<LoadCrops>(_onLoadCrops);
    on<CreateCrop>(_onCreateCrop);
    on<DeleteCrop>(_onDeleteCrop);
  }

  Future<void> _onLoadCrops(LoadCrops event, Emitter<CropsState> emit) async {
    emit(CropsLoading());
    try {
      final crops = await _repository.getCrops(event.plotId);
      emit(CropsLoaded(crops));
    } catch (e) {
      emit(CropsError('Error al cargar los cultivos.'));
    }
  }

  Future<void> _onCreateCrop(CreateCrop event, Emitter<CropsState> emit) async {
    try {
      await _repository.createCrop(event.plotId, {
        'cropType': event.cropType,
        'variety': event.variety,
        'plantedAt': event.plantedAt.toIso8601String().split('T')[0],
        'estimatedHarvest':
            event.estimatedHarvest?.toIso8601String().split('T')[0],
        'notes': event.notes,
      });
      add(LoadCrops(event.plotId));
    } catch (e) {
      emit(CropsError('Error al crear el cultivo.'));
    }
  }

  Future<void> _onDeleteCrop(DeleteCrop event, Emitter<CropsState> emit) async {
    try {
      await _repository.deleteCrop(event.plotId, event.cropId);
      add(LoadCrops(event.plotId));
    } catch (e) {
      emit(CropsError('Error al eliminar el cultivo.'));
    }
  }
}
