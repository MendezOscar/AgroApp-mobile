import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/shifts_cubit.dart';
import '../bloc/shifts_state.dart';
import '../widgets/occurrence_card.dart';
import '../widgets/create_template_sheet.dart';
import '../widgets/assign_occurrence_sheet.dart';
import '../widgets/update_occurrence_status_sheet.dart';

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  State<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage>
    with SingleTickerProviderStateMixin {
  late final ShiftsCubit _cubit;
  late final TabController _tabController;
  late final bool _isManager;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final authState = context.read<AuthBloc>().state;
    _isManager = authState is AuthAuthenticated
        ? RoleHelper.isManager(authState.user.role)
        : false;

    _cubit = sl<ShiftsCubit>()..loadOccurrences(onlyMine: !_isManager);
  }

  @override
  void dispose() {
    _cubit.close();
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTemplate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: const CreateTemplateSheet(),
      ),
    );
  }

  void _showAssign(String occurrenceId, String currentShift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: AssignOccurrenceSheet(
          occurrenceId: occurrenceId,
          currentShift: currentShift,
        ),
      ),
    );
  }

  void _showUpdateStatus(occurrence) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: UpdateOccurrenceStatusSheet(occurrence: occurrence),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _cubit.state.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) _cubit.changeDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Turnos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadOccurrences(onlyMine: !_isManager),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.wb_sunny), text: 'Diurno'),
              Tab(icon: Icon(Icons.nights_stay), text: 'Nocturno'),
            ],
          ),
        ),
        body: BlocConsumer<ShiftsCubit, ShiftsState>(
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
                // Selector de fecha
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'es')
                              .format(state.selectedDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const Spacer(),
                        if (state.unassignedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${state.unassignedCount} sin asignar',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                // Navegación de días
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _cubit.changeDate(
                          state.selectedDate.subtract(const Duration(days: 1)),
                        ),
                      ),
                      Text(
                        '${state.occurrences.length} turno(s)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _cubit.changeDate(
                          state.selectedDate.add(const Duration(days: 1)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 0),

                // Tabs de turnos
                if (state.isLoading)
                  const Expanded(child: LoadingWidget())
                else
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildShiftList(state.dayShift, state),
                        _buildShiftList(state.nightShift, state),
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
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva plantilla',
                    style: TextStyle(color: Colors.white)),
                onPressed: _showCreateTemplate,
              )
            : null,
      ),
    );
  }

  Widget _buildShiftList(List occurrences, ShiftsState state) {
    if (occurrences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No hay turnos para este día',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_isManager) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _showCreateTemplate,
                child: const Text('Crear plantilla'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => _cubit.loadOccurrences(onlyMine: !_isManager),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: occurrences.length,
        itemBuilder: (_, i) => OccurrenceCard(
          occurrence: occurrences[i],
          isManager: _isManager,
          onAssign: _isManager
              ? () => _showAssign(
                    occurrences[i].id,
                    occurrences[i].shift,
                  )
              : null,
          onUpdateStatus: () => _showUpdateStatus(occurrences[i]),
        ),
      ),
    );
  }
}
