import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';
import '../widgets/create_task_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/update_status_sheet.dart';

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

    _cubit = sl<TasksCubit>()..loadTasks(onlyMine: !_isManager);
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
              onPressed: () => _cubit.loadTasks(onlyMine: !_isManager),
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
            if (state.isLoading) return const LoadingWidget();
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
                      _buildTaskList(state.pendingTasks, state),
                      _buildTaskList(state.inProgressTasks, state),
                      _buildTaskList(state.completedTasks, state),
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

  Widget _buildTaskList(List tasks, TasksState state) {
    if (tasks.isEmpty) {
      return Center(
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
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => _cubit.loadTasks(onlyMine: !_isManager),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (_, i) => TaskCard(
          task: tasks[i],
          isManager: _isManager,
          onUpdateStatus: () => _showUpdateStatus(tasks[i]),
          onDelete: _isManager ? () => _confirmDelete(tasks[i].id) : null,
        ),
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
