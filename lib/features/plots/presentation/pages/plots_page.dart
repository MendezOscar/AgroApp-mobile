import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/geo_point.dart';
import '../../../../core/utils/role_helper.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../sensors/presentation/pages/sensors_page.dart';
import '../../domain/entities/plot_entity.dart';
import '../bloc/plots_bloc.dart';
import '../bloc/plots_event.dart';
import '../bloc/plots_state.dart';
import '../widgets/plot_card.dart';
import '../widgets/create_plot_bottom_sheet.dart';
import 'farm_map_page.dart';
import 'plot_polygon_picker_page.dart';

class PlotsPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const PlotsPage({super.key, required this.farmId, required this.farmName});

  @override
  State<PlotsPage> createState() => _PlotsPageState();
}

class _PlotsPageState extends State<PlotsPage> {
  late final PlotsBloc _plotsBloc;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _plotsBloc = sl<PlotsBloc>()..add(LoadPlots(widget.farmId));
  }

  @override
  void dispose() {
    _plotsBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  List<PlotEntity> _filterPlots(List<PlotEntity> plots) {
    final q = _searchQuery.toLowerCase();
    if (q.isEmpty) return plots;
    return plots
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            (p.soilType?.toLowerCase().contains(q) ?? false))
        .toList();
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

  Future<void> _setLocation(PlotEntity plot) async {
    final initialPoints = decodeGeoPolygon(plot.geoJson);
    final initialCenter =
        initialPoints == null ? decodeGeoPoint(plot.geoJson) : null;

    final result = await Navigator.push<List<LatLng>>(
      context,
      MaterialPageRoute(
        builder: (_) => PlotPolygonPickerPage(
          initialPoints: initialPoints,
          initialCenter: initialCenter,
        ),
      ),
    );
    if (result != null) {
      _plotsBloc.add(UpdatePlotShape(
        farmId: widget.farmId,
        plotId: plot.id,
        points: result,
      ));
    }
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
        appBar: AppBar(
          title: Text(widget.farmName),
          actions: [
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: 'Mapa de finca',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FarmMapPage(
                    farmId: widget.farmId,
                    farmName: widget.farmName,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Comparar cultivos',
              onPressed: () =>
                  context.push('/farms/${widget.farmId}/comparison'),
            ),
          ],
        ),
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
            final filtered =
                state is PlotsLoaded ? _filterPlots(state.plots) : <PlotEntity>[];
            return Column(
              children: [
                if (state is PlotsLoaded && state.isOffline)
                  const OfflineBanner(),
                if (state is PlotsLoaded && state.plots.isNotEmpty)
                  SearchField(
                    controller: _searchController,
                    hintText: 'Buscar por nombre...',
                    onChanged: (value) =>
                        setState(() => _searchQuery = value),
                  ),
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
                              : filtered.isEmpty
                                  ? EmptyStateWidget(
                                      message:
                                          'No se encontraron parcelas para "$_searchQuery"',
                                      icon: Icons.search_off,
                                    )
                                  : RefreshIndicator(
                                      color: AppTheme.primary,
                                      onRefresh: () async => _plotsBloc
                                          .add(LoadPlots(widget.farmId)),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: filtered.length,
                                        itemBuilder: (_, i) => PlotCard(
                                          plot: filtered[i],
                                          onTap: () => context.push(
                                            '/farms/${widget.farmId}/plots/${filtered[i].id}/crops',
                                            extra: filtered[i].name,
                                          ),
                                          onDelete: () =>
                                              _confirmDelete(filtered[i]),
                                          onSetLocation: () =>
                                              _setLocation(filtered[i]),
                                          onSensorsTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SensorsPage(
                                                plotId: filtered[i].id,
                                                plotName: filtered[i].name,
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
