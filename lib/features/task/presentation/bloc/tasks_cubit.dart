import 'package:flutter/foundation.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/models/paged_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/datasources/tasks_remote_datasource.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_local_repository.dart';
import 'tasks_state.dart';

const _statusKeys = {'Pending', 'InProgress', 'Completed'};

class TasksCubit extends SafeCubit<TasksState> {
  final TasksRemoteDatasource _datasource;
  final TasksLocalRepository _localRepository;
  final AuthBloc _authBloc;
  bool _onlyMine = false;
  String _activeStatus = 'Pending';

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

  TaskBucket _bucketFor(String status) {
    switch (status) {
      case 'Pending':
        return state.pending;
      case 'InProgress':
        return state.inProgress;
      default:
        return state.completed;
    }
  }

  TasksState _withBucket(String status, TaskBucket bucket) {
    switch (status) {
      case 'Pending':
        return state.copyWith(pending: bucket);
      case 'InProgress':
        return state.copyWith(inProgress: bucket);
      default:
        return state.copyWith(completed: bucket);
    }
  }

  Future<void> loadTasks(String status, {bool? onlyMine}) async {
    assert(_statusKeys.contains(status));
    if (onlyMine != null) _onlyMine = onlyMine;
    _activeStatus = status;
    emit(_withBucket(status, _bucketFor(status).copyWith(isLoading: true))
        .copyWith(error: null));
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        final raw = await _datasource.getTasks(
            onlyMine: _onlyMine, status: status, page: 1);
        final paged = PagedResult.fromJson(raw, TaskModel.fromJson);
        await _localRepository.saveTasks(paged.items);
        emit(_withBucket(
          status,
          TaskBucket(
            items: paged.items,
            page: paged.page,
            hasNextPage: paged.hasNextPage,
          ),
        ).copyWith(isOffline: false));
      } else {
        emit(_withBucket(status, await _loadBucketOffline(status))
            .copyWith(isOffline: true));
      }
    } catch (e) {
      debugPrint('TasksCubit.loadTasks($status) error: $e');
      // Solo mostrar el banner de offline si realmente no hay conexión.
      // Si hay conexión pero la petición falló (error del servidor, etc.),
      // mostrar el error real en vez de etiquetarlo como "modo offline".
      final stillOnline = await ConnectivityService.isOnline();
      if (!stillOnline) {
        try {
          emit(_withBucket(status, await _loadBucketOffline(status))
              .copyWith(isOffline: true));
          return;
        } catch (_) {
          // sin cache local tampoco — cae al error genérico abajo
        }
      }
      emit(_withBucket(status, _bucketFor(status).copyWith(isLoading: false))
          .copyWith(error: 'Error al cargar tareas'));
    }
  }

  Future<TaskBucket> _loadBucketOffline(String status) async {
    final tasks = await _localRepository.getTasks(
      onlyMine: _onlyMine,
      userId: _currentUserId,
    );
    return TaskBucket(
      items: tasks.where((t) => t.status == status).toList(),
      hasNextPage: false,
    );
  }

  Future<void> loadMoreTasks(String status) async {
    final bucket = _bucketFor(status);
    if (!bucket.hasNextPage || bucket.isLoadingMore || state.isOffline) return;
    emit(_withBucket(status, bucket.copyWith(isLoadingMore: true)));
    try {
      final nextPage = bucket.page + 1;
      final raw = await _datasource.getTasks(
          onlyMine: _onlyMine, status: status, page: nextPage);
      final paged = PagedResult.fromJson(raw, TaskModel.fromJson);
      final current = _bucketFor(status);
      emit(_withBucket(
        status,
        current.copyWith(
          items: [...current.items, ...paged.items],
          page: paged.page,
          hasNextPage: paged.hasNextPage,
          isLoadingMore: false,
        ),
      ));
    } catch (e) {
      emit(_withBucket(status, _bucketFor(status).copyWith(isLoadingMore: false)));
    }
  }

  Future<void> createTask(Map<String, dynamic> data) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.createTask(data);
        await loadTasks(_activeStatus);
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
        await loadTasks(_activeStatus);
        emit(state.copyWith(success: 'Estado actualizado'));
      } else {
        // Actualizar localmente y guardar pendiente
        await _localRepository.updateTaskStatus(id, status, notes);
        emit(_withBucket(_activeStatus, await _loadBucketOffline(_activeStatus))
            .copyWith(isOffline: true, success: 'Estado guardado localmente'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error al actualizar estado'));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final isOnline = await ConnectivityService.isOnline();
      if (isOnline) {
        await _datasource.deleteTask(id);
        await loadTasks(_activeStatus);
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
