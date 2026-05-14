import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/sensor_device_entity.dart';
import '../bloc/sensors_cubit.dart';
import '../bloc/sensors_state.dart';
import '../widgets/add_sensor_sheet.dart';
import '../widgets/sensor_device_card.dart';
import 'sensor_detail_page.dart';

class SensorsPage extends StatefulWidget {
  final String plotId;
  final String plotName;

  const SensorsPage({super.key, required this.plotId, required this.plotName});

  @override
  State<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends State<SensorsPage> {
  late final SensorsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SensorsCubit>()..loadDevices(widget.plotId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showAddSensor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: AddSensorSheet(plotId: widget.plotId),
      ),
    );
  }

  void _openDetail(SensorDeviceEntity device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SensorDetailPage(
          device: device,
          plotId: widget.plotId,
        ),
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
          title: Text('Sensores — ${widget.plotName}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _cubit.loadDevices(widget.plotId),
            ),
          ],
        ),
        body: BlocConsumer<SensorsCubit, SensorsState>(
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
            if (state.isLoadingDevices) return const LoadingWidget();

            if (state.devices.isEmpty) {
              return EmptyStateWidget(
                message: 'No hay sensores en esta parcela',
                icon: Icons.sensors_off,
                actionLabel: 'Agregar sensor',
                onAction: _showAddSensor,
              );
            }

            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async => _cubit.loadDevices(widget.plotId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Resumen
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryChip(
                          label: 'Total',
                          value: '${state.devices.length}',
                          color: AppTheme.primary,
                        ),
                        _SummaryChip(
                          label: 'Activos',
                          value:
                              '${state.devices.where((d) => d.isActive).length}',
                          color: Colors.green,
                        ),
                        _SummaryChip(
                          label: 'Inactivos',
                          value:
                              '${state.devices.where((d) => !d.isActive).length}',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  // Lista de dispositivos
                  ...state.devices.map((device) => SensorDeviceCard(
                        device: device,
                        onTap: () => _openDetail(device),
                      )),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label:
              const Text('Nuevo sensor', style: TextStyle(color: Colors.white)),
          onPressed: _showAddSensor,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
