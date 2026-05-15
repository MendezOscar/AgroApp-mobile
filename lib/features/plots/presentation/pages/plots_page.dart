import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../sensors/presentation/pages/sensors_page.dart';
import '../../domain/entities/plot_entity.dart';
import '../bloc/plots_bloc.dart';
import '../bloc/plots_event.dart';
import '../bloc/plots_state.dart';
import '../widgets/plot_card.dart';
import '../widgets/create_plot_bottom_sheet.dart';

class PlotsPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const PlotsPage({super.key, required this.farmId, required this.farmName});

  @override
  State<PlotsPage> createState() => _PlotsPageState();
}

class _PlotsPageState extends State<PlotsPage> {
  late final PlotsBloc _plotsBloc;

  @override
  void initState() {
    super.initState();
    _plotsBloc = sl<PlotsBloc>()..add(LoadPlots(widget.farmId));
  }

  @override
  void dispose() {
    _plotsBloc.close();
    super.dispose();
  }

  void _showCreatePlot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _plotsBloc,
        child: CreatePlotBottomSheet(farmId: widget.farmId),
      ),
    );
  }

  void _confirmDelete(PlotEntity plot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar parcela'),
        content: Text('¿Estás seguro de eliminar "${plot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _plotsBloc
                  .add(DeletePlot(farmId: widget.farmId, plotId: plot.id));
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _plotsBloc,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(widget.farmName)),
        body: BlocConsumer<PlotsBloc, PlotsState>(
          listener: (context, state) {
            if (state is PlotsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.error),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (state is PlotsLoaded && state.isOffline)
                  const OfflineBanner(),
                Expanded(
                  child: state is PlotsLoading
                      ? const LoadingWidget()
                      : state is PlotsLoaded
                          ? state.plots.isEmpty
                              ? EmptyStateWidget(
                                  message: 'No tienes parcelas registradas',
                                  icon: Icons.grid_view_outlined,
                                  actionLabel: 'Agregar parcela',
                                  onAction: _showCreatePlot,
                                )
                              : RefreshIndicator(
                                  color: AppTheme.primary,
                                  onRefresh: () async =>
                                      _plotsBloc.add(LoadPlots(widget.farmId)),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.plots.length,
                                    itemBuilder: (_, i) => PlotCard(
                                      plot: state.plots[i],
                                      onTap: () => context.push(
                                        '/farms/${widget.farmId}/plots/${state.plots[i].id}/crops',
                                        extra: state.plots[i].name,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(state.plots[i]),
                                      onSensorsTap: () => Navigator.push(
                                        // ← nuevo
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SensorsPage(
                                            plotId: state.plots[i].id,
                                            plotName: state.plots[i].name,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                          : const SizedBox(),
                ),
              ],
            );
          },
        ),
        floatingActionButton: RoleGuard(
          permission: RoleHelper.canCreatePlot,
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nueva parcela',
                style: TextStyle(color: Colors.white)),
            onPressed: _showCreatePlot,
          ),
        ),
      ),
    );
  }
}
