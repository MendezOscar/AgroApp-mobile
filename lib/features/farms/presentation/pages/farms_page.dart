import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/initial_sync_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/alert_badge.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/farm_entity.dart';
import '../bloc/farms_bloc.dart';
import '../bloc/farms_event.dart';
import '../bloc/farms_state.dart';
import '../widgets/farm_card.dart';
import '../widgets/create_farm_bottom_sheet.dart';

class FarmsPage extends StatefulWidget {
  const FarmsPage({super.key});

  @override
  State<FarmsPage> createState() => _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> {
  late final FarmsBloc _farmsBloc;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _farmsBloc = sl<FarmsBloc>()..add(LoadFarms());
    _runInitialSync();
  }

  Future<void> _runInitialSync() async {
    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) return;

    setState(() => _isSyncing = true);
    await sl<InitialSyncService>().syncAll();
    if (mounted) {
      setState(() => _isSyncing = false);
      _farmsBloc.add(LoadFarms());
    }
  }

  @override
  void dispose() {
    _farmsBloc.close();
    super.dispose();
  }

  void _showCreateFarm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _farmsBloc,
        child: const CreateFarmBottomSheet(),
      ),
    );
  }

  void _confirmDelete(FarmEntity farm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar finca'),
        content: Text('¿Estás seguro de eliminar "${farm.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _farmsBloc.add(DeleteFarm(farm.id));
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
      value: _farmsBloc,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Mis Fincas'),
          actions: [
            if (_isSyncing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            const AlertBadge(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
                context.go('/login');
              },
            ),
            FutureBuilder<int>(
              future: sl<SyncService>().getPendingCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    backgroundColor: Colors.orange,
                    label: Text(
                      '$count pendiente${count > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    avatar:
                        const Icon(Icons.sync, color: Colors.white, size: 16),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<FarmsBloc, FarmsState>(
          listener: (context, state) {
            if (state is FarmsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Banner offline
                if (state is FarmsLoaded && state.isOffline)
                  const OfflineBanner(),
                // Resto del contenido
                Expanded(
                  child: state is FarmsLoading
                      ? const LoadingWidget()
                      : state is FarmsLoaded
                          ? state.farms.isEmpty
                              ? EmptyStateWidget(
                                  message: 'No tienes fincas registradas',
                                  icon: Icons.agriculture_outlined,
                                  actionLabel: 'Agregar finca',
                                  onAction: _showCreateFarm,
                                )
                              : RefreshIndicator(
                                  color: AppTheme.primary,
                                  onRefresh: () async =>
                                      _farmsBloc.add(LoadFarms()),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.farms.length,
                                    itemBuilder: (_, i) => FarmCard(
                                      farm: state.farms[i],
                                      onTap: () => context.push(
                                        '/farms/${state.farms[i].id}/plots',
                                        extra: state.farms[i].name,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(state.farms[i]),
                                    ),
                                  ),
                                )
                          : const SizedBox(),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label:
              const Text('Nueva finca', style: TextStyle(color: Colors.white)),
          onPressed: _showCreateFarm,
        ),
      ),
    );
  }
}
