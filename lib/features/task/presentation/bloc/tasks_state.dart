import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

class TaskBucket extends Equatable {
  final List<TaskEntity> items;
  final int page;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingMore;

  const TaskBucket({
    this.items = const [],
    this.page = 1,
    this.hasNextPage = false,
    this.isLoading = false,
    this.isLoadingMore = false,
  });

  TaskBucket copyWith({
    List<TaskEntity>? items,
    int? page,
    bool? hasNextPage,
    bool? isLoading,
    bool? isLoadingMore,
  }) =>
      TaskBucket(
        items: items ?? this.items,
        page: page ?? this.page,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [items, page, hasNextPage, isLoading, isLoadingMore];
}

class TasksState extends Equatable {
  final TaskBucket pending;
  final TaskBucket inProgress;
  final TaskBucket completed;
  final bool isOffline;
  final String? error;
  final String? success;
  final String selectedStatus;

  const TasksState({
    this.pending = const TaskBucket(),
    this.inProgress = const TaskBucket(),
    this.completed = const TaskBucket(),
    this.isOffline = false,
    this.error,
    this.success,
    this.selectedStatus = 'all',
  });

  TasksState copyWith({
    TaskBucket? pending,
    TaskBucket? inProgress,
    TaskBucket? completed,
    bool? isOffline,
    String? error,
    String? success,
    String? selectedStatus,
  }) =>
      TasksState(
        pending: pending ?? this.pending,
        inProgress: inProgress ?? this.inProgress,
        completed: completed ?? this.completed,
        isOffline: isOffline ?? this.isOffline,
        error: error,
        success: success,
        selectedStatus: selectedStatus ?? this.selectedStatus,
      );

  int get overdueCount => [...pending.items, ...inProgress.items, ...completed.items]
      .where((t) => t.isOverdue)
      .length;

  bool get isLoading => pending.isLoading || inProgress.isLoading || completed.isLoading;

  @override
  List<Object?> get props =>
      [pending, inProgress, completed, isOffline, error, success, selectedStatus];
}
