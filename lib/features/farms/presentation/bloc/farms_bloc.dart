import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/repositories/farms_local_repository.dart';
import '../../domain/repositories/farms_repository.dart';
import 'farms_event.dart';
import 'farms_state.dart';

class FarmsBloc extends Bloc<FarmsEvent, FarmsState> {
  final FarmsRepository _repository;
  final FarmsLocalRepository _localRepository;

  FarmsBloc(this._repository, this._localRepository) : super(FarmsInitial()) {
    on<LoadFarms>(_onLoadFarms);
    on<CreateFarm>(_onCreateFarm);
    on<DeleteFarm>(_onDeleteFarm);
  }

  Future<void> _onLoadFarms(LoadFarms event, Emitter<FarmsState> emit) async {
    emit(FarmsLoading());
    try {
      final isOnline = await ConnectivityService.isOnline();

      if (isOnline) {
        // Online: cargar de API y guardar en local
        final farms = await _repository.getFarms();
        await _localRepository.saveFarms(farms);
        emit(FarmsLoaded(farms, isOffline: false));
      } else {
        // Offline: cargar de SQLite
        final farms = await _localRepository.getFarms();
        emit(FarmsLoaded(farms, isOffline: true));
      }
    } catch (e) {
      // Si falla la API, intentar desde local
      try {
        final farms = await _localRepository.getFarms();
        emit(FarmsLoaded(farms, isOffline: true));
      } catch (_) {
        emit(FarmsError('Error al cargar las fincas.'));
      }
    }
  }

  Future<void> _onCreateFarm(CreateFarm event, Emitter<FarmsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      final data = {
        'name': event.name,
        'description': event.description,
        'lat': event.lat,
        'lng': event.lng,
        'areaHa': event.areaHa,
        'country': event.country,
        'region': event.region,
      };

      if (isOnline) {
        await _repository.createFarm(data);
      } else {
        // Guardar como pendiente
        await _localRepository.savePendingCreate(data);
      }
      add(LoadFarms());
    } catch (e) {
      emit(FarmsError('Error al crear la finca.'));
    }
  }

  Future<void> _onDeleteFarm(DeleteFarm event, Emitter<FarmsState> emit) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _repository.deleteFarm(event.id);
        add(LoadFarms());
      } else {
        emit(FarmsError('Sin conexión. No se puede eliminar ahora.'));
      }
    } catch (e) {
      emit(FarmsError('Error al eliminar la finca.'));
    }
  }
}
