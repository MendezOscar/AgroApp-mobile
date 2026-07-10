import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/cost_history_chart.dart';
import '../widgets/metric_card.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/weather_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DashboardCubit>()..loadDashboard();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: AppTheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/images/app_icon.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('AgroApp',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14)),
                                  const Spacer(),
                                  // Badge alertas
                                  GestureDetector(
                                    onTap: () => context.push('/alerts'),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(Icons.notifications_outlined,
                                            color: Colors.white),
                                        if (state.unreadAlerts > 0)
                                          Positioned(
                                            right: -4,
                                            top: -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${state.unreadAlerts}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Panel de monitoreo',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (state.isLoading)
                  const SliverFillRemaining(child: LoadingWidget())
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clima de la finca
                          if (state.weather != null) ...[
                            WeatherCard(weather: state.weather!),
                            const SizedBox(height: 24),
                          ],

                          // Métricas actuales
                          if (state.latestReading != null) ...[
                            const Text('Lecturas actuales',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: [
                                if (state.latestReading!.temperature != null)
                                  MetricCard(
                                    icon: Icons.thermostat,
                                    label: 'Temperatura',
                                    value:
                                        '${state.latestReading!.temperature!.toStringAsFixed(1)}°C',
                                    color: Colors.orange,
                                  ),
                                if (state.latestReading!.humidityAir != null)
                                  MetricCard(
                                    icon: Icons.water_drop,
                                    label: 'Humedad aire',
                                    value:
                                        '${state.latestReading!.humidityAir!.toStringAsFixed(0)}%',
                                    color: Colors.blue,
                                  ),
                                if (state.latestReading!.humiditySoil != null)
                                  MetricCard(
                                    icon: Icons.grass,
                                    label: 'Humedad suelo',
                                    value:
                                        '${state.latestReading!.humiditySoil!.toStringAsFixed(0)}%',
                                    color: AppTheme.primary,
                                  ),
                                if (state.latestReading!.luminosity != null)
                                  MetricCard(
                                    icon: Icons.wb_sunny,
                                    label: 'Luminosidad',
                                    value:
                                        '${(state.latestReading!.luminosity! / 1000).toStringAsFixed(1)}klx',
                                    color: Colors.amber,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Resumen general
                          const Text('Resumen',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: MetricCard(
                                icon: Icons.eco,
                                label: 'Cultivos activos',
                                value: '${state.activeCrops}',
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricCard(
                                icon: Icons.sensors,
                                label: 'Sensores',
                                value: '${state.devices.length}',
                                color: Colors.purple,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          // Gastos mensuales
                          if (state.costHistory.isNotEmpty) ...[
                            CostHistoryChart(history: state.costHistory),
                            const SizedBox(height: 24),
                          ],

                          // Gráficas
                          if (state.readings.isNotEmpty) ...[
                            const Text('Histórico de sensores',
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
                            const SizedBox(height: 24),
                          ],

                          // Sin sensores
                          if (state.readings.isEmpty &&
                              state.latestReading == null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(Icons.sensors_off,
                                        size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No hay sensores configurados',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Registra un dispositivo IoT en tus parcelas para ver datos en tiempo real',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primary,
          child: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _cubit.loadDashboard(),
        ),
      ),
    );
  }
}
