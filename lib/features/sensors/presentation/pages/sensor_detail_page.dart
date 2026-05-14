import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/sensor_device_entity.dart';
import '../bloc/sensors_cubit.dart';
import '../bloc/sensors_state.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/sensor_metric_tile.dart';

class SensorDetailPage extends StatefulWidget {
  final SensorDeviceEntity device;
  final String plotId;

  const SensorDetailPage({
    super.key,
    required this.device,
    required this.plotId,
  });

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  late final SensorsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SensorsCubit>()..loadReadings(widget.device.id);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showSendReadingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: _SendReadingSheet(deviceId: widget.device.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
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
            return CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.primary,
                  title: Text(widget.device.deviceCode,
                      style: const TextStyle(color: Colors.white)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => _cubit.loadReadings(widget.device.id),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info del dispositivo
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.sensors,
                                          color: AppTheme.primary, size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.device.deviceCode,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Text(
                                            widget.device.deviceType
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Estado
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: widget.device.isActive
                                            ? Colors.green
                                                .withValues(alpha: 0.1)
                                            : Colors.grey
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.device.isActive
                                            ? 'Activo'
                                            : 'Inactivo',
                                        style: TextStyle(
                                          color: widget.device.isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _DeviceInfo(
                                      label: 'Firmware',
                                      value: widget.device.firmwareVer ?? 'N/A',
                                      icon: Icons.memory,
                                    ),
                                    if (widget.device.batteryPct != null)
                                      _DeviceInfo(
                                        label: 'Batería',
                                        value: '${widget.device.batteryPct}%',
                                        icon: Icons.battery_full,
                                        color: widget.device.batteryPct! > 20
                                            ? AppTheme.primary
                                            : Colors.red,
                                      ),
                                    if (widget.device.lastSeenAt != null)
                                      _DeviceInfo(
                                        label: 'Último ping',
                                        value: DateFormat('dd/MM HH:mm')
                                            .format(widget.device.lastSeenAt!),
                                        icon: Icons.access_time,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Últimas lecturas
                        if (state.isLoadingReadings)
                          const LoadingWidget()
                        else if (state.latestReading != null) ...[
                          const Text('Última lectura',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.6,
                            children: [
                              SensorMetricTile(
                                icon: Icons.thermostat,
                                label: 'Temperatura',
                                value: state.latestReading!.temperature
                                    ?.toStringAsFixed(1),
                                unit: '°C',
                                color: Colors.orange,
                              ),
                              SensorMetricTile(
                                icon: Icons.water_drop,
                                label: 'Hum. Suelo',
                                value: state.latestReading!.humiditySoil
                                    ?.toStringAsFixed(0),
                                unit: '%',
                                color: AppTheme.primary,
                              ),
                              SensorMetricTile(
                                icon: Icons.air,
                                label: 'Hum. Aire',
                                value: state.latestReading!.humidityAir
                                    ?.toStringAsFixed(0),
                                unit: '%',
                                color: Colors.blue,
                              ),
                              SensorMetricTile(
                                icon: Icons.wb_sunny,
                                label: 'Luminosidad',
                                value: state.latestReading!.luminosity != null
                                    ? (state.latestReading!.luminosity! / 1000)
                                        .toStringAsFixed(1)
                                    : null,
                                unit: 'klx',
                                color: Colors.amber,
                              ),
                              SensorMetricTile(
                                icon: Icons.science,
                                label: 'pH',
                                value:
                                    state.latestReading!.ph?.toStringAsFixed(1),
                                unit: '',
                                color: Colors.purple,
                              ),
                              SensorMetricTile(
                                icon: Icons.electrical_services,
                                label: 'EC',
                                value:
                                    state.latestReading!.ec?.toStringAsFixed(0),
                                unit: 'µS',
                                color: Colors.teal,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Actualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(state.latestReading!.recordedAt)}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 24),
                        ] else ...[
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.sensors_off,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('Sin lecturas disponibles',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(
                                      'Envía una lectura de prueba para verificar la conexión',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Gráficas históricas
                        if (state.readings.isNotEmpty) ...[
                          const Text('Historial',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          SensorChart(
                            title: 'Humedad del suelo',
                            unit: '%',
                            color: AppTheme.primary,
                            readings: state.readings,
                            getValue: (r) => r.humiditySoil,
                          ),
                          const SizedBox(height: 12),
                          SensorChart(
                            title: 'Temperatura',
                            unit: '°C',
                            color: Colors.orange,
                            readings: state.readings,
                            getValue: (r) => r.temperature,
                          ),
                          const SizedBox(height: 12),
                          SensorChart(
                            title: 'Humedad del aire',
                            unit: '%',
                            color: Colors.blue,
                            readings: state.readings,
                            getValue: (r) => r.humidityAir,
                          ),
                          const SizedBox(height: 80),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text('Enviar lectura de prueba',
              style: TextStyle(color: Colors.white)),
          onPressed: _showSendReadingSheet,
        ),
      ),
    );
  }
}

class _DeviceInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _DeviceInfo({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[500], size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}

// Sheet para enviar lectura de prueba
class _SendReadingSheet extends StatefulWidget {
  final String deviceId;
  const _SendReadingSheet({required this.deviceId});

  @override
  State<_SendReadingSheet> createState() => _SendReadingSheetState();
}

class _SendReadingSheetState extends State<_SendReadingSheet> {
  final _tempCtrl = TextEditingController(text: '28.5');
  final _humAirCtrl = TextEditingController(text: '65.0');
  final _humSoilCtrl = TextEditingController(text: '45.0');
  final _luxCtrl = TextEditingController(text: '8500');
  final _phCtrl = TextEditingController(text: '6.5');
  final _ecCtrl = TextEditingController(text: '1200');

  @override
  void dispose() {
    _tempCtrl.dispose();
    _humAirCtrl.dispose();
    _humSoilCtrl.dispose();
    _luxCtrl.dispose();
    _phCtrl.dispose();
    _ecCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SensorsCubit, SensorsState>(
      listener: (context, state) {
        if (state.success != null || state.error != null) {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Enviar lectura de prueba',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'Simula una lectura del ESP32 para probar la conexión',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _tempCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        prefixIcon: Icon(Icons.thermostat)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _humAirCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Hum. Aire (%)',
                        prefixIcon: Icon(Icons.air)),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _humSoilCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Hum. Suelo (%)',
                        prefixIcon: Icon(Icons.water_drop)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _luxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Lux', prefixIcon: Icon(Icons.wb_sunny)),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _phCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'pH', prefixIcon: Icon(Icons.science)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _ecCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'EC (µS)',
                        prefixIcon: Icon(Icons.electrical_services)),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              BlocBuilder<SensorsCubit, SensorsState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: state.isSendingReading
                      ? null
                      : () {
                          context.read<SensorsCubit>().sendTestReading(
                            widget.deviceId,
                            {
                              'temperature': double.tryParse(_tempCtrl.text),
                              'humidityAir': double.tryParse(_humAirCtrl.text),
                              'humiditySoil':
                                  double.tryParse(_humSoilCtrl.text),
                              'luminosity': double.tryParse(_luxCtrl.text),
                              'ph': double.tryParse(_phCtrl.text),
                              'ec': double.tryParse(_ecCtrl.text),
                            },
                          );
                        },
                  child: state.isSendingReading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar lectura'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
