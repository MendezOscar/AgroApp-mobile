import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/shifts_remote_datasource.dart';
import '../../data/models/task_occurrence_model.dart';
import '../../data/models/task_template_model.dart';
import '../../data/repositories/shifts_local_repository.dart';
import 'shifts_state.dart';

class ShiftsCubit extends SafeCubit<ShiftsState> {
  final ShiftsRemoteDatasource _datasource;
  final ShiftsLocalRepository _localRepository;
  final AuthBloc _authBloc;

  ShiftsCubit(
    this._datasource,
    this._localRepository,
    this._authBloc,
  ) : super(ShiftsState(selectedDate: DateTime.now()));

  String? get _currentUserId {
    final state = _authBloc.state;
    if (state is AuthAuthenticated) return state.user.tenantId;
    return null;
  }

  Future<void> loadOccurrences({
    DateTime? date,
    bool onlyMine = false,
  }) async {
    final targetDate = date ?? state.selectedDate;
    emit(
        state.copyWith(isLoading: true, error: null, selectedDate: targetDate));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _datasource.getOccurrences(
            date: targetDate, onlyMine: onlyMine);
        final occurrences =
            data.map((e) => TaskOccurrenceModel.fromJson(e)).toList();
        await _localRepository.saveOccurrences(occurrences);
        emit(state.copyWith(
            occurrences: occurrences, isLoading: false, isOffline: false));
      } else {
        final occurrences = await _localRepository.getOccurrences(
          date: targetDate,
          onlyMine: onlyMine,
          userId: _currentUserId,
        );
        emit(state.copyWith(
            occurrences: occurrences, isLoading: false, isOffline: true));
      }
    } catch (e) {
      try {
        final occurrences = await _localRepository.getOccurrences(
          date: targetDate,
        );
        emit(state.copyWith(
            occurrences: occurrences, isLoading: false, isOffline: true));
      } catch (_) {
        emit(state.copyWith(isLoading: false, error: 'Error al cargar turnos'));
      }
    }
  }

  Future<void> loadTemplates() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        emit(state.copyWith(isLoading: false, isOffline: true));
        return;
      }
      final data = await _datasource.getTemplates();
      emit(state.copyWith(
        templates: data.map((e) => TaskTemplateModel.fromJson(e)).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, error: 'Error al cargar plantillas'));
    }
  }

  Future<void> createTemplate(Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        emit(state.copyWith(
            error: 'Sin conexión. No se pueden crear plantillas offline.'));
        return;
      }
      await _datasource.createTemplate(data);
      await loadTemplates();
      emit(state.copyWith(success: 'Plantilla creada y turnos generados'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al crear plantilla'));
    }
  }

  Future<void> assignOccurrence(
      String id, String assignedTo, String? shift) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (!isOnline) {
        emit(state.copyWith(
            error: 'Sin conexión. No se pueden asignar turnos offline.'));
        return;
      }
      await _datasource.assignOccurrence(id, assignedTo, shift);
      await loadOccurrences();
      emit(state.copyWith(success: 'Turno asignado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al asignar turno'));
    }
  }

  Future<void> updateStatus(String id, String status, String? notes) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.updateStatus(id, status, notes);
        await loadOccurrences();
      } else {
        // Actualizar localmente
        await _localRepository.updateStatus(id, status, notes);
        final occurrences = await _localRepository.getOccurrences(
          date: state.selectedDate,
        );
        emit(state.copyWith(
            occurrences: occurrences,
            isOffline: true,
            success: 'Estado guardado localmente'));
      }
      emit(state.copyWith(success: 'Estado actualizado'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar estado'));
    }
  }

  void changeDate(DateTime date) {
    loadOccurrences(date: date);
  }
}
