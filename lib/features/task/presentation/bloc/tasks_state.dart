import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

class TasksState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final bool isOffline; // ← nuevo
  final String? error;
  final String? success;
  final String selectedStatus;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.isOffline = false, // ← nuevo
    this.error,
    this.success,
    this.selectedStatus = 'all',
  });

  TasksState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    bool? isOffline, // ← nuevo
    String? error,
    String? success,
    String? selectedStatus,
  }) =>
      TasksState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        isOffline: isOffline ?? this.isOffline, // ← nuevo
        error: error,
        success: success,
        selectedStatus: selectedStatus ?? this.selectedStatus,
      );

  List<TaskEntity> get pendingTasks =>
      tasks.where((t) => t.status == 'Pending').toList();
  List<TaskEntity> get inProgressTasks =>
      tasks.where((t) => t.status == 'InProgress').toList();
  List<TaskEntity> get completedTasks =>
      tasks.where((t) => t.status == 'Completed').toList();
  int get overdueCount => tasks.where((t) => t.isOverdue).length;

  @override
  List<Object?> get props =>
      [tasks, isLoading, isOffline, error, success, selectedStatus];
}
