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
import '../../domain/entities/crop_entity.dart';
import '../bloc/crops_bloc.dart';
import '../bloc/crops_event.dart';
import '../bloc/crops_state.dart';
import '../widgets/crop_card.dart';
import '../widgets/create_crop_bottom_sheet.dart';

class CropsPage extends StatefulWidget {
  final String plotId;
  final String plotName;

  const CropsPage({super.key, required this.plotId, required this.plotName});

  @override
  State<CropsPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<CropsPage> {
  late final CropsBloc _cropsBloc;

  @override
  void initState() {
    super.initState();
    _cropsBloc = sl<CropsBloc>()..add(LoadCrops(widget.plotId));
  }

  @override
  void dispose() {
    _cropsBloc.close();
    super.dispose();
  }

  void _showCreateCrop() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cropsBloc,
        child: CreateCropBottomSheet(plotId: widget.plotId),
      ),
    );
  }

  void _confirmDelete(CropEntity crop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cultivo'),
        content: Text('¿Estás seguro de eliminar "${crop.cropType}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _cropsBloc
                  .add(DeleteCrop(plotId: widget.plotId, cropId: crop.id));
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
      value: _cropsBloc,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(widget.plotName)),
        body: BlocConsumer<CropsBloc, CropsState>(
          listener: (context, state) {
            if (state is CropsError) {
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
                // Banner offline
                if (state is CropsLoaded && state.isOffline)
                  const OfflineBanner(),
                // Contenido
                Expanded(
                  child: state is CropsLoading
                      ? const LoadingWidget()
                      : state is CropsLoaded
                          ? state.crops.isEmpty
                              ? EmptyStateWidget(
                                  message: 'No tienes cultivos registrados',
                                  icon: Icons.grass_outlined,
                                  actionLabel: 'Agregar cultivo',
                                  onAction: _showCreateCrop,
                                )
                              : RefreshIndicator(
                                  color: AppTheme.primary,
                                  onRefresh: () async =>
                                      _cropsBloc.add(LoadCrops(widget.plotId)),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.crops.length,
                                    itemBuilder: (_, i) => CropCard(
                                      crop: state.crops[i],
                                      onTap: () => context.push(
                                        '/crop-detail',
                                        extra: state.crops[i],
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(state.crops[i]),
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
          permission: RoleHelper.canCreateCrop,
          child: FloatingActionButton.extended(
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nuevo cultivo',
                style: TextStyle(color: Colors.white)),
            onPressed: _showCreateCrop,
          ),
        ),
      ),
    );
  }
}
