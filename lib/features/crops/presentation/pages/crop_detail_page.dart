import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../domain/entities/crop_entity.dart';
import '../bloc/crop_detail_cubit.dart';
import '../bloc/crop_detail_state.dart';
import '../widgets/tabs/fertilization_tab.dart';
import '../widgets/tabs/images_tab.dart';
import '../widgets/tabs/irrigation_tab.dart';
import '../widgets/tabs/labor_tab.dart';
import '../widgets/sheets/add_fertilization_sheet.dart';
import '../widgets/sheets/add_irrigation_sheet.dart';
import '../widgets/sheets/add_labor_sheet.dart';

class CropDetailPage extends StatefulWidget {
  final CropEntity crop;

  const CropDetailPage({super.key, required this.crop});

  @override
  State<CropDetailPage> createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CropDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cubit = sl<CropDetailCubit>();

    // Cargar tab inicial
    _cubit.loadIrrigations(widget.crop.id);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      switch (_tabController.index) {
        case 0:
          _cubit.loadIrrigations(widget.crop.id);
          break;
        case 1:
          _cubit.loadFertilizations(widget.crop.id);
          break;
        case 2:
          _cubit.loadLabors(widget.crop.id);
          break;
        case 3:
          _cubit.loadImages(widget.crop.id);
          break;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showAddSheet() {
    final cropId = widget.crop.id;
    final Widget? sheet = switch (_tabController.index) {
      0 => AddIrrigationSheet(cropId: cropId),
      1 => AddFertilizationSheet(cropId: cropId),
      2 => AddLaborSheet(cropId: cropId),
      _ => null,
    };

    if (sheet == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(value: _cubit, child: sheet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: BlocListener<CropDetailCubit, CropDetailState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          child: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 200, // ← aumentar altura
                pinned: true,
                backgroundColor: AppTheme.primary,
                title: Text(
                  '${widget.crop.cropType}'
                  '${widget.crop.variety != null ? ' — ${widget.crop.variety}' : ''}',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 56, 16, 56),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _InfoChip(
                              icon: Icons.calendar_today,
                              label: 'Siembra',
                              value: fmt.format(widget.crop.plantedAt),
                            ),
                            if (widget.crop.estimatedHarvest != null)
                              _InfoChip(
                                icon: Icons.event_available,
                                label: 'Cosecha est.',
                                value:
                                    fmt.format(widget.crop.estimatedHarvest!),
                              ),
                            _InfoChip(
                              icon: Icons.circle,
                              label: 'Estado',
                              value: widget.crop.status,
                              color: widget.crop.status == 'Active'
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  isScrollable: false,
                  tabs: const [
                    Tab(icon: Icon(Icons.water_drop, size: 20), text: 'Riego'),
                    Tab(
                        icon: Icon(Icons.science, size: 20),
                        text: 'Fertilización'),
                    Tab(
                        icon: Icon(Icons.agriculture, size: 20),
                        text: 'Labores'),
                    Tab(
                        icon: Icon(Icons.photo_library, size: 20),
                        text: 'Fotos'),
                  ],
                ),
              ),
            ],
            body: Column(
              children: [
                // Banner offline
                BlocBuilder<CropDetailCubit, CropDetailState>(
                  builder: (context, state) => state.isOffline
                      ? const OfflineBanner()
                      : const SizedBox(),
                ),
                // Tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      IrrigationTab(cropId: widget.crop.id),
                      FertilizationTab(cropId: widget.crop.id),
                      LaborTab(cropId: widget.crop.id),
                      ImagesTab(cropId: widget.crop.id),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<CropDetailCubit, CropDetailState>(
          builder: (context, state) {
            if (_tabController.index == 3) return const SizedBox();
            return FloatingActionButton.extended(
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                ['Riego', 'Fertilización', 'Labor'][_tabController.index],
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: _showAddSheet,
            );
          },
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 18),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
