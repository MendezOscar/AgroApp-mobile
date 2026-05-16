import '../../../../core/bloc/safe_cubit.dart';
import '../../data/datasources/tasks_remote_datasource.dart';
import '../../data/models/task_model.dart';
import 'tasks_state.dart';

class TasksCubit extends SafeCubit<TasksState> {
  final TasksRemoteDatasource _datasource;

  TasksCubit(this._datasource) : super(const TasksState());

  Future<void> loadTasks({bool onlyMine = false}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _datasource.getTasks(onlyMine: onlyMine);
      emit(state.copyWith(
        tasks: data.map((e) => TaskModel.fromJson(e)).toList(),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Error al cargar tareas'));
    }
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    try {
      await _datasource.createTask(data);
      await loadTasks();
      emit(state.copyWith(success: 'Tarea creada correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al crear tarea'));
    }
  }

  Future<void> updateStatus(String id, String status, String? notes) async {
    try {
      await _datasource.updateStatus(id, status, notes);
      await loadTasks();
      emit(state.copyWith(success: 'Estado actualizado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar estado'));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _datasource.deleteTask(id);
      await loadTasks();
      emit(state.copyWith(success: 'Tarea eliminada'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar tarea'));
    }
  }
}
