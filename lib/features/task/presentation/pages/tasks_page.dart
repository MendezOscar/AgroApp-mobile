import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/paginated_list.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';
import '../widgets/create_task_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/update_status_sheet.dart';

const _tabStatuses = ['Pending', 'InProgress', 'Completed'];

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late final TasksCubit _cubit;
  late final TabController _tabController;
  late final bool _isManager;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final authState = context.read<AuthBloc>().state;
    _isManager = authState is AuthAuthenticated
        ? RoleHelper.isManager(authState.user.role)
        : false;

    _cubit = sl<TasksCubit>()
      ..loadTasks(_tabStatuses[0], onlyMine: !_isManager);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _cubit.loadTasks(_tabStatuses[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: const CreateTaskSheet(),
      ),
    );
  }

  void _showUpdateStatus(task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: UpdateStatusSheet(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Tareas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  _cubit.loadTasks(_tabStatuses[_tabController.index]),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Pendientes'),
              Tab(text: 'En progreso'),
              Tab(text: 'Completadas'),
            ],
          ),
        ),
        body: BlocConsumer<TasksCubit, TasksState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppTheme.error),
              );
            }
            if (state.success != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.success!),
                    backgroundColor: AppTheme.primary),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (state.isOffline) const OfflineBanner(),
                // Resumen
                if (state.overdueCount > 0)
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${state.overdueCount} tarea(s) vencida(s)',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                // Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskList(_tabStatuses[0], state.pending),
                      _buildTaskList(_tabStatuses[1], state.inProgress),
                      _buildTaskList(_tabStatuses[2], state.completed),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _isManager
            ? FloatingActionButton.extended(
                backgroundColor: AppTheme.primary,
                icon: const Icon(Icons.add_task, color: Colors.white),
                label: const Text('Nueva tarea',
                    style: TextStyle(color: Colors.white)),
                onPressed: _showCreateTask,
              )
            : null,
      ),
    );
  }

  Widget _buildTaskList(String status, TaskBucket bucket) {
    if (bucket.isLoading && bucket.items.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return PaginatedList<TaskEntity>(
      items: bucket.items,
      hasNextPage: bucket.hasNextPage,
      isLoadingMore: bucket.isLoadingMore,
      onLoadMore: () => _cubit.loadMoreTasks(status),
      onRefresh: () async => _cubit.loadTasks(status),
      emptyWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay tareas aquí',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      itemBuilder: (_, task, __) => TaskCard(
        task: task,
        isManager: _isManager,
        onUpdateStatus: () => _showUpdateStatus(task),
        onDelete: _isManager ? () => _confirmDelete(task.id) : null,
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _cubit.deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
