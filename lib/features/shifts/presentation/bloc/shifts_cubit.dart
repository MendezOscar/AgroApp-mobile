import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/shifts_remote_datasource.dart';
import '../../data/models/task_occurrence_model.dart';
import '../../data/models/task_template_model.dart';
import 'shifts_state.dart';

class ShiftsCubit extends SafeCubit<ShiftsState> {
  final ShiftsRemoteDatasource _datasource;

  ShiftsCubit(this._datasource)
      : super(ShiftsState(selectedDate: DateTime.now()));

  Future<void> loadOccurrences({
    DateTime? date,
    bool onlyMine = false,
  }) async {
    final targetDate = date ?? state.selectedDate;
    emit(
        state.copyWith(isLoading: true, error: null, selectedDate: targetDate));
    try {
      final data = await _datasource.getOccurrences(
          date: targetDate, onlyMine: onlyMine);
      emit(state.copyWith(
        occurrences: data.map((e) => TaskOccurrenceModel.fromJson(e)).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error al cargar turnos'));
    }
  }

  Future<void> loadTemplates() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
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
      await _datasource.assignOccurrence(id, assignedTo, shift);
      await loadOccurrences();
      emit(state.copyWith(success: 'Turno asignado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al asignar turno'));
    }
  }

  Future<void> updateStatus(String id, String status, String? notes) async {
    try {
      await _datasource.updateStatus(id, status, notes);
      await loadOccurrences(onlyMine: true);
      emit(state.copyWith(success: 'Estado actualizado'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar estado'));
    }
  }

  void changeDate(DateTime date) {
    loadOccurrences(date: date);
  }
}
