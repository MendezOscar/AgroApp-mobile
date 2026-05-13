import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/repositories/crops_local_repository.dart';
import '../../domain/repositories/crops_repository.dart';
import 'crops_event.dart';
import 'crops_state.dart';

class CropsBloc extends Bloc<CropsEvent, CropsState> {
  final CropsRepository _repository;
  final CropsLocalRepository _localRepository;

  CropsBloc(this._repository, this._localRepository) : super(CropsInitial()) {
    on<LoadCrops>(_onLoadCrops);
    on<CreateCrop>(_onCreateCrop);
    on<DeleteCrop>(_onDeleteCrop);
  }

  Future<void> _onLoadCrops(LoadCrops event, Emitter<CropsState> emit) async {
    emit(CropsLoading());
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final crops = await _repository.getCrops(event.plotId);
        await _localRepository.saveCrops(event.plotId, crops);
        emit(CropsLoaded(crops, isOffline: false));
      } else {
        final crops = await _localRepository.getCrops(event.plotId);
        emit(CropsLoaded(crops, isOffline: true));
      }
    } catch (e) {
      try {
        final crops =
            await _localRepository.getCrops((state as dynamic).plotId ?? '');
        emit(CropsLoaded(crops, isOffline: true));
      } catch (_) {
        emit(CropsError('Error al cargar los cultivos.'));
      }
    }
  }

  Future<void> _onCreateCrop(CreateCrop event, Emitter<CropsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      final data = {
        'cropType': event.cropType,
        'variety': event.variety,
        'plantedAt': event.plantedAt.toIso8601String().split('T')[0],
        'estimatedHarvest':
            event.estimatedHarvest?.toIso8601String().split('T')[0],
        'notes': event.notes,
      };

      if (isOnline) {
        await _repository.createCrop(event.plotId, data);
      } else {
        await _localRepository.savePendingCreate(event.plotId, data);
      }
      add(LoadCrops(event.plotId));
    } catch (e) {
      emit(CropsError('Error al crear el cultivo.'));
    }
  }

  Future<void> _onDeleteCrop(DeleteCrop event, Emitter<CropsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _repository.deleteCrop(event.plotId, event.cropId);
        add(LoadCrops(event.plotId));
      } else {
        emit(CropsError('Sin conexión. No se puede eliminar ahora.'));
      }
    } catch (e) {
      emit(CropsError('Error al eliminar el cultivo.'));
    }
  }
}
