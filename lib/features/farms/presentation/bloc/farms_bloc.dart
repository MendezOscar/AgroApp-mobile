import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/farms_repository.dart';
import 'farms_event.dart';
import 'farms_state.dart';

class FarmsBloc extends Bloc<FarmsEvent, FarmsState> {
  final FarmsRepository _repository;

  FarmsBloc(this._repository) : super(FarmsInitial()) {
    on<LoadFarms>(_onLoadFarms);
    on<CreateFarm>(_onCreateFarm);
    on<DeleteFarm>(_onDeleteFarm);
  }

  Future<void> _onLoadFarms(LoadFarms event, Emitter<FarmsState> emit) async {
    emit(FarmsLoading());
    try {
      final farms = await _repository.getFarms();
      emit(FarmsLoaded(farms));
    } catch (e) {
      emit(FarmsError('Error al cargar las fincas.'));
    }
  }

  Future<void> _onCreateFarm(CreateFarm event, Emitter<FarmsState> emit) async {
    try {
      await _repository.createFarm({
        'name': event.name,
        'description': event.description,
        'lat': event.lat,
        'lng': event.lng,
        'areaHa': event.areaHa,
        'country': event.country,
        'region': event.region,
      });
      add(LoadFarms());
    } catch (e) {
      emit(FarmsError('Error al crear la finca.'));
    }
  }

  Future<void> _onDeleteFarm(DeleteFarm event, Emitter<FarmsState> emit) async {
    try {
      await _repository.deleteFarm(event.id);
      add(LoadFarms());
    } catch (e) {
      emit(FarmsError('Error al eliminar la finca.'));
    }
  }
}
