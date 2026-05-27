import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/tasks_remote_datasource.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_local_repository.dart';
import 'tasks_state.dart';

class TasksCubit extends SafeCubit<TasksState> {
  final TasksRemoteDatasource _datasource;
  final TasksLocalRepository _localRepository;
  final AuthBloc _authBloc;

  TasksCubit(
    this._datasource,
    this._localRepository,
    this._authBloc,
  ) : super(const TasksState());

  String? get _currentUserId {
    final state = _authBloc.state;
    if (state is AuthAuthenticated) return state.user.tenantId;
    return null;
  }

  Future<void> loadTasks({bool onlyMine = false}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final data = await _datasource.getTasks(onlyMine: onlyMine);
        final tasks = data.map((e) => TaskModel.fromJson(e)).toList();
        await _localRepository.saveTasks(tasks);
        emit(state.copyWith(tasks: tasks, isLoading: false, isOffline: false));
      } else {
        final tasks = await _localRepository.getTasks(
          onlyMine: onlyMine,
          userId: _currentUserId,
        );
        emit(state.copyWith(tasks: tasks, isLoading: false, isOffline: true));
      }
    } catch (e) {
      try {
        final tasks = await _localRepository.getTasks(
          onlyMine: onlyMine,
          userId: _currentUserId,
        );
        emit(state.copyWith(tasks: tasks, isLoading: false, isOffline: true));
      } catch (_) {
        emit(state.copyWith(isLoading: false, error: 'Error al cargar tareas'));
      }
    }
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.createTask(data);
        await loadTasks();
        emit(state.copyWith(success: 'Tarea creada correctamente'));
      } else {
        emit(state.copyWith(
            error: 'Sin conexión. No se pueden crear tareas offline.'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al crear tarea'));
    }
  }

  Future<void> updateStatus(String id, String status, String? notes) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.updateStatus(id, status, notes);
        await loadTasks();
      } else {
        // Actualizar localmente y guardar pendiente
        await _localRepository.updateTaskStatus(id, status, notes);
        final tasks = await _localRepository.getTasks();
        emit(state.copyWith(
            tasks: tasks,
            isOffline: true,
            success: 'Estado guardado localmente'));
      }
      emit(state.copyWith(success: 'Estado actualizado'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar estado'));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.deleteTask(id);
        await loadTasks();
        emit(state.copyWith(success: 'Tarea eliminada'));
      } else {
        emit(state.copyWith(
            error: 'Sin conexión. No se pueden eliminar tareas offline.'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al eliminar tarea'));
    }
  }
}
